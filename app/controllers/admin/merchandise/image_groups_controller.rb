# Image groups allow any variant to have "variant specific" images.  Thus a red shit would show as red an not green.

class Admin::Merchandise::ImageGroupsController < Admin::BaseController
  helper_method :sort_column, :sort_direction, :products
  def index
    keyword = filter_helper(params)
    @image_groups = ImageGroup.order(sort_column + " " + sort_direction).where(keyword).
                                     paginate(:page => pagination_page, :per_page => pagination_rows)
    if current_user.designer?
      @image_groups = @image_groups.where(["user_id =?",current_user.id])
    end                                       
    @action = "index"
    @columns = [["Name","name@string"],["Created At","created_at@date"],["Updated At","updated_at@date"]]    
    @nodes = ImageGroup.all.select("name").map{|x| x.name[0] if x.name}.uniq                                                                                  
  end

  def show
    @image_group = ImageGroup.find(params[:id])
  end

  def new
    @image_group = ImageGroup.new
  end

  def create
    @image_group = ImageGroup.new(allowed_params)
    if @image_group.save
      redirect_to edit_admin_merchandise_image_group_url( @image_group ), :notice => "Successfully created image group."
    else
      render :new
    end
  end

  def edit
    @image_group  = ImageGroup.includes(:images).find(params[:id])
  end

  def update
    @image_group = ImageGroup.find(params[:id])
    if @image_group.update_attributes(allowed_params)
      redirect_to [:admin, :merchandise, @image_group], :notice  => "Successfully updated image group."
    else
      render :edit
    end
  end

  private

    def allowed_params
      params.require(:image_group).permit!
    end

    def products
      if current_user.designer?
        @products ||= Product.where(["user_id =?",current_user.id]).map{|p|[p.name, p.id]}
      else
        @products ||= Product.all.map{|p|[p.name, p.id]}
      end 
    end

    def sort_column
      ImageGroup.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
