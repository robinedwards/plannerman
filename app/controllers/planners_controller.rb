class PlannersController < ApplicationController
  # GET /planners
  # GET /planners.json
  def index
    @planners = Planner.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @planners }
    end
  end

  # GET /planners/1
  # GET /planners/1.json
  def show
    @planner = Planner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @planner }
    end
  end

  # GET /planners/new
  # GET /planners/new.json
  def new
    @planner = Planner.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @planner }
    end
  end

  # GET /planners/1/edit
  def edit
    @planner = Planner.find(params[:id])
  end

  # POST /planners
  # POST /planners.json
  def create
    @planner = Planner.new(params[:planner])

    respond_to do |format|
      if @planner.save
        format.html { redirect_to @planner, notice: 'Planner was successfully created.' }
        format.json { render json: @planner, status: :created, location: @planner }
      else
        format.html { render action: "new" }
        format.json { render json: @planner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /planners/1
  # PUT /planners/1.json
  def update
    @planner = Planner.find(params[:id])

    respond_to do |format|
      if @planner.update_attributes(params[:planner])
        format.html { redirect_to @planner, notice: 'Planner was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @planner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /planners/1
  # DELETE /planners/1.json
  def destroy
    @planner = Planner.find(params[:id])
    @planner.destroy

    respond_to do |format|
      format.html { redirect_to planners_url }
      format.json { head :no_content }
    end
  end
end
