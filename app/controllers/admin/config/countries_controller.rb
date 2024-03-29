class Admin::Config::CountriesController < Admin::Config::BaseController
  helper_method :sort_column, :sort_direction
  def index
    keyword = filter_helper(params)
    @countries = Country.order(sort_column + " " + sort_direction)
    @active_countries = Country.active_countries.where(keyword).order(sort_column + " " + sort_direction).
                                              paginate(:page => pagination_page, :per_page => pagination_rows)
    @action = "index"
    @columns = [["Name","name@string"],["Created At","created_at@date"],["Updated At","updated_at@date"]]    
    @nodes = Country.active_countries.select("name").map{|x| x.name[0] if x.name}.uniq                                                                                           
  end

  def update
    @country = Country.find(params[:id])
    @country.active = true
    if @country.save
      redirect_to admin_config_countries_url, :notice  => "Successfully activated country."
    else
      render :edit
    end
  end

  def destroy
    @country = Country.find(params[:id])
    @country.active = false
    @country.save
    redirect_to admin_config_countries_url, :notice => "Successfully inactivated country."
  end

  private

    def sort_column
      Country.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
