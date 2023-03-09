class Product < ApplicationRecord
    include Rails.application.routes.url_helpers

    has_many :variants, inverse_of: :product, dependent: :destroy
    accepts_nested_attributes_for :variants, :allow_destroy => true
    has_many_attached :images, dependent: :destroy
    validates :images, size: { less_than: 10.megabytes , message: 'размер файла должен быть меньше 10Мб' }
    validates :title, presence: true
    before_save :normalize_data_white_space
    # scope :with_images, -> { joins(:images_attachments).uniq }
    scope :without_images, -> { left_joins(:images_attachments).where(active_storage_attachments: { id: nil }) }
    scope :not_nill, -> { where("quantity > ?", 0) }


    ImageBackground = [['1','#b10ced'],['2','#8c0ced'],['3','#6d0ced'],['4','#2a0ced'],['5','#0c4ced'],['6','#052d7d'],['7','#054b7d'],['8','#057d61'],['9','#5d7d05'],['10','#7d5b05']].freeze
    ImageSize = ['600x600','800x800','1200x1200','1600x1600'].freeze

    
    def self.ransackable_scopes(auth_object = nil)
		[:with_images, :without_images, :lt_5, :gt_5]
	end

    def self.with_images
        ids = Product.joins(:images_attachments).uniq.map(&:id)
        Product.where(id: ids)
    end

    def self.lt_5
        ids = Product.includes(:variants).select{|pr| pr.variants.count < 5}
        Product.where(id: ids)
    end

    def self.gt_5
        ids = Product.includes(:variants).select{|pr| pr.variants.count > 5}
        Product.where(id: ids)
    end

    def image_urls
        return unless self.images.attached?
        self.images.map do |pr_image|
            # puts pr_image.to_s
            pr_image.blob.attributes.slice('filename', 'byte_size', 'id').merge(url: pr_image_url(pr_image))
        end
    end

    def pr_image_url(image)
        rails_blob_path(image, only_path: true)
    end


    
    private

    def normalize_data_white_space
        self.attributes.each do |key, value|
            self[key] = value.squish if value.respond_to?("squish")
        end
      end
  
end
