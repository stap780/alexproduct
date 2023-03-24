class ProductsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource
  before_action :set_product, only: [:show, :edit, :update, :destroy, :create_variants]

  # GET /products
  def index
    #@products = Product.all
    @search = Product.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @products = @search.result.paginate(page: params[:page], per_page: 100).includes(images_attachments: :blob)
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    @product.variants.build
  end

  # GET /products/1/edit
  def edit
    # @product.variants.build if @product.variants.empty?
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /products/1
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

# POST /products
  def delete_selected
    @products = Product.find(params[:ids])
    @products.each do |product|
        product.destroy
    end
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end

  def delete_image
    ActiveStorage::Attachment.where(id: params[:image_id])[0].purge
    respond_to do |format|
      #format.html { redirect_to edit_product_path(params[:id]), notice: 'Image was successfully deleted.' }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end

  def import
    Rails.env.development? ? Services::Import.product : ImportProductJob.perform_later
    redirect_to products_path, notice: 'Запущен процесс Обновление Товаров InSales. Дождитесь выполнении'
  end

  def avito
    Rails.env.development? ? Services::Export.avito : ExportAvitoJob.perform_later
    redirect_to products_path, notice: 'Запущен процесс создания файла авито. Дождитесь выполнении'
  end

  def drom
    Rails.env.development? ? Services::Export.drom : ExportDromJob.perform_later
    redirect_to products_path, notice: 'Запущен процесс создания файла авито. Дождитесь выполнении'
  end

  def create_variants
    Rails.env.development? ? Services::Import.create_variants(@product) : ProductVariantJob.perform_later(@product)
    redirect_to @product, notice: 'Запущен процесс создания вариантов. Дождитесь выполнении'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:sku, :title, :desc, :quantity, :costprice, :price, :offer_id,:barcode, :avito_param, :avito_date_begin, images: [], images_attachments_attributes: [:id, :_destroy], :variants_attributes =>[:id, :sku, :product_id, :title, :desc, :period, :_destroy])
    end
end
