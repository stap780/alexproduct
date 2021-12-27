class KpsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_user_role!
  before_action :active_storage_host
  before_action :get_order
  before_action :set_kp, only: %i[show edit update destroy]
  autocomplete :product, :title, :extra_data => [:id, :sku], :display_value => :sku_title, 'data-noMatchesLabel' => 'нет товара'

  # GET /kps
  def index
    # @kps = Kp.all
    @search = @order.kps.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @kps = @search.result.paginate(page: params[:page], per_page: 30)
  end

  def index_all
    # @kps = Kp.all
    @search = Kp.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @kps = @search.result.paginate(page: params[:page], per_page: 100)
  end

  # GET /kps/1
  def show; end

  # GET /kps/new
  def new
    @kp = @order.kps.build
  end

  # GET /kps/1/edit
  def edit; end

  # POST /kps
  def create
    @kp = @order.kps.build(kp_params)

    respond_to do |format|
      if @kp.save
        format.html { redirect_to edit_order_path(@order), notice: 'Kp was successfully created.' }
        format.json { render :show, status: :created, location: @kp }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kps/1
  def update
    respond_to do |format|
      if @kp.update(kp_params)
        format.html { redirect_to edit_order_path(@order), notice: 'Kp was successfully updated.' }
        format.json { render :show, status: :ok, location: @kp }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kps/1
  def destroy
    @kp.destroy
    respond_to do |format|
      format.html { redirect_to order_kps_path(@order), notice: 'Kp was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /kps
  def delete_selected
    @kps = @order.kps.find(params[:ids])
    @kps.each do |kp|
      kp.destroy
    end
    respond_to do |format|
      format.html { redirect_to order_kps_path(@order), notice: 'Kp was successfully destroyed.' }
      format.json { render json: { status: 'ok', message: 'destroyed' } }
    end
  end

  def print1
    @kp = Kp.find(params[:id])
    # puts @kp.present?
    @our_company = @kp.order.companykp1
    @company = @kp.order.company
    respond_to do |format|
      format.html
      format.pdf do
          render :pdf => "КП1 #{@kp.id}",
                 :template => "kps/print1.html.erb",
                 :show_as_html => params.key?('debug'),
     						 :margin => {top: 15, left: 0, right: 0, bottom: 20 },
     						 header:  {
     						 		html: { template:'kps/print1_header.html.erb'},
     						 		spacing: 3
     						 		# locals: {},
                    # right: 'Стр [page] из [topage]'
     						 		},
     						 footer: {
     							 html: { template:'kps/print1_footer.html.erb'},
     							 	:spacing => 3,
     								locals: {}
     								#right: '_______________________(подпись)                  _______________________(подпись)            [page] из [topage]'
     								}
        end
    end
  end

  def print2
    @kp = Kp.find(params[:id])
    @client = @kp.order.client
    @company = @kp.order.company
    @our_company = @kp.order.companykp2
    @kp_products_data = []
    @kp.kp_products.each do |kp|
      data = {
              sku: kp.product.sku,
              # image_url: rails_representation_url(kp.product.images.first.variant(combine_options: {auto_orient: true, thumbnail: '40x40', gravity: 'center', extent: '40x40' }).processed, only_path: true),
              image_url: kp.product.images.first,
              title: kp.product.title,
              price: kp.price,
              quantity: kp.quantity,
              sum: kp.sum.to_f.round(2)
            }
      @kp_products_data << data
    end
    @kp_products = @kp_products_data.sort_by{ |hsh| hsh[:title] }

    # puts @kp_products_data
    respond_to do |format|
      format.html
      format.pdf do
          render pdf: "КП2 #{@kp.id}",
                 template: "kps/print2.html.erb",
                 page_size: 'A4',
                 orientation: "Portrait",
                 show_as_html: params.key?('debug'),
                 margin: {top: 12, left: 5, right: 5, bottom: 15},
                 footer: {
                   spacing: 5,
                   right: 'Стр [page] из [topage]'
                 }
        end
    end
  end

  def print3
    @kp = Kp.find(params[:id])
    @company = @kp.order.company
    @our_company = @kp.order.companykp3
    @kp_products_data = []
    @kp.kp_products.each do |kp|
      data = {
              sku: kp.product.sku,
              # image_url: rails_representation_url(kp.product.images.first.variant(combine_options: {auto_orient: true, thumbnail: '40x40', gravity: 'center', extent: '40x40' }).processed, only_path: true),
              image_url: kp.product.images.first,
              title: kp.product.title,
              price: kp.price,
              quantity: kp.quantity,
              sum: kp.sum.to_f.round(2)
            }
      @kp_products_data << data
    end
    @kp_products = @kp_products_data.sort_by{ |hsh| hsh[:sku] }
    respond_to do |format|
      format.html
      format.pdf do
              render pdf: "КП3 #{@kp.id}",
                     page_size: 'A4',
                     template: "kps/print3.html.erb",
                     orientation: "Portrait",
                     lowquality: true,
                     zoom: 1,
                     dpi: 75,
                     show_as_html: params.key?('debug')
                     #header: { right: 'Стр [page] из [topage]' }
        end
    end
  end
  # это для модалки для загрузки файла
  def file_import
    respond_to do |format|
      format.js
    end
  end

  def import
    @kp = Kp.find(params[:id])
    Kp.import(params[:file], params[:order_id], params[:id])
    flash[:notice] = 'Products was successfully import'
    redirect_to edit_order_kp_path(@order, @kp)
	end


  private

  def get_order
    @order = Order.find(params[:order_id]) if params[:order_id].present?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_kp
    @kp = @order.kps.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def kp_params
    params.require(:kp).permit(:vid, :status, :title, :order_id, :extra, :comment, kp_products_attributes: %i[id quantity price sum product_id _destroy])
  end
end
