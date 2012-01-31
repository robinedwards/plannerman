class SubdomainsController < ApplicationController
  # GET /subdomains
  # GET /subdomains.json
  def index
    @subdomains = Subdomain.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subdomains }
    end
  end

  # GET /subdomains/1
  # GET /subdomains/1.json
  def show
    @subdomain = Subdomain.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subdomain }
    end
  end
end
