class ProductImport < ApplicationService

  def self.product
    require 'open-uri'
    puts '=====>>>> СТАРТ MS XML '+Time.now.to_s
    url = "https://online.moysklad.ru/api/yandex/market/b26c08a6-9a47-11ed-0a80-0bf700011888/offer/c5eeb21a-9c0a-11ed-0a80-0f670017a5ec"
		filename = url.split('/').last
    download = open(url, :read_timeout => 240 )
		download_path = "#{Rails.public_path}"+"/"+filename
		IO.copy_stream(download, download_path)

    data = Nokogiri::XML(open(download_path))
    offers = data.xpath("//offer")

    categories = {}
    doc_categories = data.xpath("//category")
    doc_categories.each do |c|
      categories[c["id"]] = c.text
    end

    offers.each_with_index do |pr, index|
      # params = pr.xpath("param").present? ? pr.xpath("param").map{ |p| p["name"]+":"+p.text if p["name"] != "Цена EBAY" && p["name"] != "Цена Etsy"}.join(' --- ') : ''
      avito_params = pr.xpath("param").select{ |p| p if p["name"].include?("avito") }.reject(&:blank?)
      sku_check = pr.xpath("param").present? ? pr.xpath("param").select{|p| p if p["name"].include?("article") } : []
      sku = sku_check.present? ? sku_check[0].text.strip : ''

      data = {
        offer_id: pr["id"],
        sku: sku,
        title: pr.xpath("name").text,
        barcode: pr.xpath("barcode").text,
        desc: pr.xpath("description").text,
        price: pr.xpath("price").text.to_f,
        avito_param: avito_params.map{|p| p["name"].gsub('avito::','')+":"+p.text}.reject(&:blank?).join("---"),
        quantity: pr.xpath("count").text
      }

      check_product = Product.where(offer_id: data[:offer_id]).first
      if check_product.present?
        check_product.update!(data)
        product = check_product
      else
        product = Product.create!(data)
      end
      
      images = pr.xpath("picture").present? ? pr.xpath("picture").map(&:text) : nil
      pr_filenames = product.images.map(&:filename).reject(&:blank?)
      if images.present?
        images.each do |img_link|
          img_filename = img_link.split('/').last.split('.').first
          if !pr_filenames.include?(img_filename)
            file = download_file(img_link)
            product.images.attach(io: file, filename: img_filename, content_type: "image/jpg")
          end
        end
      end
      break if Rails.env.development? && index == 5
	  end

    # Product.where(quantity: nil).update_all(quantity: 0)
    File.delete(download_path) if File.file?(download_path).present?

    puts '=====>>>> FINISH MS XML '+Time.now.to_s

    current_process = "=====>>>> FINISH InSales EXCEL - #{Time.now.to_s} - Закончили обновление каталога товаров"
  	# ProductMailer.notifier_process(current_process).deliver_now
  end

private

  def download_file(url)
    ascii_url = URI.encode(url)
    response = Net::HTTP.get_response(URI.parse(ascii_url))
    StringIO.new(response.body)
  end

end
