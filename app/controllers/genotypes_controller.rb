class GenotypesController < ApplicationController

  before_filter :require_user, except: [ :show, :feed,:index,:dump_download ]
  helper_method :sort_column, :sort_direction

  def index
    @genotypes = Genotype.order(sort_column + " " + sort_direction)
    @genotypes_paginate = @genotypes.paginate(:page => params[:page],:per_page => 20)
    @filelink = FileLink.find_by_description("all genotypes and phenotypes archive").url unless FileLink.find_by_description("all genotypes and phenotypes archive") == nil
    respond_to do |format|
      format.html
      format.xml 
    end
  end

  def dump_download
    @filelink = FileLink.find_by_description("all genotypes and phenotypes archive").url unless FileLink.find_by_description("all genotypes and phenotypes archive") == nil
    if @filelink != nil
	redirect_to @filelink
    else
      flash[:notice]="Sorry, there is no data-dump yet. If you register with openSNP you could be the first one to create one!"
      redirect_to :action => :index
    end
  end

  def new
    @genotype = Genotype.new
    # current user is always stored in the method 'current_user',
    # not in the variable '@current_user'
    @genotype.user = current_user
    @genotype.uploadtime=Time.new
    @title = "Add Genotype-File"

    respond_to do |format|
      format.html
      format.xml { render :xml => @user }
    end
  end

  def create
    @genotype = Genotype.new()
    @genotype.uploadtime = Time.new 
    @genotype.user_id = current_user.id
    @genotype.filetype=params[:genotype][:filetype]
    @genotype.originalfilename=params[:genotype][:filename].original_filename if params[:genotype][:filename]
    @genotype.data=params[:genotype][:filename].read if params[:genotype][:filename]

    respond_to do |format|
      if @genotype.save
        if current_user.has_sequence == false
            current_user.toggle!(:has_sequence)
        end

        # award for genotyping-upload
        @award = Achievement.find_by_award("Published genotyping")
        if UserAchievement.find_by_achievement_id_and_user_id(@award.id,current_user.id) == nil
          UserAchievement.create(:user_id => current_user.id, :achievement_id => @award.id)
				flash[:achievement] = %(Congratulations! You've unlocked an achievement: <a href="#{url_for(@award)}">#{@award.award}</a>).html_safe
        end

        @genotype.move_file
        Resque.enqueue(Preparsing, @genotype.id)
        format.html { redirect_to(current_user, :notice => 'Genotype was successfully uploaded! Parsing and stuff might take a couple of hours.') }
        format.xml { render :xml => current_user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @genotype = Genotype.find(params[:id])
    @user = User.find_by_id(@genotype.user_id)

    @title = "Genotypes"
    respond_to do |format|
      format.html
      format.xml
    end
  end

  def do_upload_genotype
    @genotype=Genotype.new()
    @genotype.user=current_user
    @genotype.uploadtime=Time.new
    @genotype.filetype=params[:genotype][:filetype]
    @genotype.originalfilename=params[:genotype][:filename].ofindriginal_filename if params[:genotype][:filename]

    if @genotype.save
      @genotype.move_file

      flash[:notice]="File upload successful!"
      redirect_to :action => :info_page
    else
      render :action=>"upload_genotype"
    end

    respond_to do |format|
      format.html
    end
  end

  def feed
    # for rss-feeds
    @genotypes = Genotype.all(:order => "created_at DESC", :limit => 20)
    render :action => "rss", :layout => false
  end

  def destroy
    @user = current_user
    @genotype = Genotype.find_by_id(params[:id])
    File.delete(::Rails.root.to_s+"/public/data/"+ @genotype.fs_filename)
    Resque.enqueue(Deletegenotype, @genotype)
    if @genotype.delete
      flash[:notice] = "Genotyping was successfully deleted."
      if @user.genotypes.length != 0
        @user.toggle!(:has_sequence)
        @user.update_attributes(:sequence_link => nil)
      end
      redirect_to current_user
    end
  end

  def get_dump
    Resque.enqueue(Zipfulldata, current_user.email)
    respond_to do |format|
      format.html
      format.xml
    end
  end

  private 

  def sort_column
    Genotype.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
