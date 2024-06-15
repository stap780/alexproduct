class ProductsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource
  before_action :set_product, only: [:show, :edit, :update, :destroy, :create_variants, :image_upload]

  # GET /products
  def index
    #@products = Product.all
    @search = Product.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @products = @search.result.paginate(page: params[:page], per_page: 100).includes(images_attachments: :blob)
  end

  # GET /products/1
  def show
    redirect_to products_url, notice: "Не туда пошёл"
  end

  # GET /products/new
  def new
    @product = Product.new
    # @product.variants.build
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
        format.html { redirect_to products_url, notice: "Product was successfully updated." }
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

  def image_upload
    params.require(:blob_signed_id)
    signed_id = params["blob_signed_id"]
    upload_blob = ActiveStorage::Blob.find_signed(signed_id)
    filename = upload_blob.filename
    content_type = upload_blob.content_type
    @product.images.attach(upload_blob)

    @blob = upload_blob

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = t(".success") }
    end
  end
  
  def delete_image
    @blob_id = params[:blob_id]

    ActiveStorage::Attachment.find(params[:blob_id]).destroy

    respond_to do |format|
      flash.now[:notice] = t(".success")
      format.turbo_stream  do
        render turbo_stream: [
          turbo_stream.remove(@blob_id),
          render_turbo_flash
        ]
      end
    end
  end

  def import
    ImportProductJob.perform_later
    respond_to do |format|
      flash.now[:notice] = "Запущен процесс Обновление Товаров Дождитесь выполнении"
      format.turbo_stream  do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  def avito
    ExportAvitoJob.perform_later
    respond_to do |format|
    flash.now[:notice] = "Запущен процесс создания файла авито. Дождитесь выполнении"
    format.turbo_stream  do
      render turbo_stream: [
        render_turbo_flash
      ]
    end
    end
  end

  def drom
    ExportDromJob.perform_later
    respond_to do |format|
    flash.now[:notice] = "Запущен процесс создания файла drom. Дождитесь выполнении"
    format.turbo_stream  do
      render turbo_stream: [
        render_turbo_flash
      ]
    end
    end
  end

  def create_variants
    # ProductVariantJob.perform_later(@product.id)
    @var_count = 10 #29
    if @product.variants.size < @var_count
        start_count = @product.variants.size
        calc_loop = @var_count-start_count
        for a in 1..calc_loop do
            variant = @product.variants.create!(status: "New", sku: @product.sku, title: @product.title, desc: @product.desc, period: start_count+a)
            variant.update!(status: "Process")
            VariantImageJob.perform_later(@product.id, variant.id) if @product.images.present?
        end
    end
    respond_to do |format|
      flash.now[:notice] = "Запустили"
      format.turbo_stream  do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:avito_id,:sku, :title, :desc, :quantity, :costprice, :price, :offer_id,:barcode, :avito_param, :avito_date_begin, images: [], :variants_attributes =>[:id, :status, :sku, :product_id, :title, :desc, :period, :_destroy])
    end
end
