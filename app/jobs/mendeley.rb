require "resque"
require "rubygems"
require "net/http"
require "json"

class Mendeley
  @queue = :mendeley
  
  def self.perform(snp)
    @snp = Snp.find_by_id(snp["snp"]["id"].to_i)
    
    key_handle = File.open(::Rails.root.to_s+"/key_mendeley.txt")
    api_key = key_handle.readline.rstrip
    
    url = "http://api.mendeley.com/oapi/documents/search/"+@snp.name+"/?consumer_key="+api_key

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue
      retry
    end
    
    data = resp.body
    result = JSON.parse(data)
    
    if result["total_results"] != 0
      print "mendeley: Got papers\n"
      result["documents"].each do |document|
        mendeley_url = document["mendeley_url"]
        uuid = document["uuid"].to_s
        first_author = document["authors"][0]["forename"]+" "+document["authors"][0]["surname"]
        title = document["title"]
        pub_year = document["year"]
        doi = document["doi"]
        
        if MendeleyPaper.find_all_by_uuid(uuid) == []
          print "-> paper is new\n"
          @mendeley_paper = MendeleyPaper.new()
          @mendeley_paper.mendeley_url = mendeley_url
          @mendeley_paper.first_author = first_author
          @mendeley_paper.pub_year = pub_year
          @mendeley_paper.title = title
          @mendeley_paper.uuid = uuid
          if doi != []
            @mendeley_paper.doi = doi
          end
          @mendeley_paper.snp_id = @snp.id
                    
          @mendeley_paper.save

          @snp.ranking = @snp.mendeley_paper.count + 2*@snp.plos_paper.count + 5*@snp.snpedia_paper.count
          @snp.save
          print "-> Written paper\n"
        else
          print "-> paper is old\n"
        end
        Resque.enqueue(MendeleyDetails,@mendeley_paper)
      end
    end
    else
      print "mendeley: No papers found\n"
  end
end