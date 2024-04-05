class VariantImageJob < ApplicationJob
    queue_as :variant_image
  
  
    def perform(product_id,variant_id)
      # Do something later
      product = Product.find_by_id(product_id)
      image_ids = product.images.map{|img| img.id}
      variant = Variant.find_by_id(variant_id)
      index = product.variants.order(:id).each_with_index.map{|var, i| i if var.id == variant_id}.reject(&:blank?).join.to_i

      success = CreateVariantImage.call(variant_id, index, image_ids)
      if success
        variant.update!(status: "Finish")
      else
        variant.update!(status: "Error")
      end

    end
  
  end