class VariantsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource
  before_action :set_variant, only: [:show, :edit, :update, :create_images, :destroy]

  # GET /variants
  def index
    #@variants = Variant.all
    @search = Variant.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @variants = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /variants/1
  def show
  end

  # GET /variants/new
  def new
    @variant = Variant.new
    @product_id = params[:product_id].present? ? params[:product_id] : nil
    respond_to do |format|
      # flash.now[:notice] = "Запустили"
      format.turbo_stream  do
        render turbo_stream: [
          turbo_stream.replace("new_variant", partial: "variants/form", locals: {variant: @variant, product_id: @product_id})
          #render_turbo_flash
        ]
      end
    end
  end

  # GET /variants/1/edit
  def edit
  end

  # POST /variants
  def create
    @variant = Variant.new(variant_params)

    respond_to do |format|
      if @variant.save
        format.turbo_stream { flash.now[:success] = "Variant was successfully created." }
        format.html { redirect_to @variant, notice: "Variant was successfully created." }
        format.json { render :show, status: :created, location: @variant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @variant.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /variants/1
  def update
    respond_to do |format|
      if @variant.update(variant_params)
        format.turbo_stream { flash.now[:success] = "Variant was successfully updated." }
        format.html { redirect_to @variant, notice: "Variant was successfully updated." }
        format.json { render :show, status: :ok, location: @variant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @variant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /variants/1
  def destroy
    @variant.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:success] = "Variant was successfully destroyed." }
      format.html { redirect_to variants_url, notice: "Variant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def create_images
    VariantImageJob.perform_later(@variant.product.id, @variant.id) if @variant.product.images.present?
    @variant.update!(status: "Process")
    respond_to do |format|
      flash.now[:notice] = "Запустили"
      format.turbo_stream  do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
    # variant = Variant.find(params[:id])
    # variant.create_images(params[:background], params[:size])
    # respond_to do |format|
    #   format.html { redirect_back(fallback_location: root_path,  notice: "Создали картинки" )}
    #   format.json { head :no_content }
    # end
  end

# POST /variants
  def delete_selected
    @variants = Variant.find(params[:ids])
    @variants.each do |variant|
        variant.destroy
    end
    respond_to do |format|
      format.html { redirect_to variants_url, notice: "Variant was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_variant
      @variant = Variant.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def variant_params
      params.require(:variant).permit(:status, :sku, :title, :desc, :product_id, :period, images: [])
    end
end
