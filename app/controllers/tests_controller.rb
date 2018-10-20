class TestsController < Simpler::Controller

  def index
    @tests = Test.all
    # render plain: "Who who !"
    render 'tests/index'
  end

  def show
    @test = Test[set_params]
    status 201
    render 'tests/show'
  end

  def new

  end

  def create

  end

  private

  def set_params
    params[:id][0]
  end

end
