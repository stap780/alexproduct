class Services::Export

    def self.avito
        puts "Формируем avito "+"#{Time.zone.now}"  
        file_name =  "avito.xml"  
        products = Product.not_nill.with_images
        xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8'){ |xml|
        
            xml.send(:'Ads', :formatVersion => '3', :target => "Avito.ru") { 
            
                products.each do |product|
                    id = product.id.to_s
                    time_begin = product.avito_date_begin.present? ? product.avito_date_begin.strftime("%Y-%m-%dT09:00:00+03:00").to_s : (Time.now.in_time_zone.strftime("%Y-%m-%d %H:%M")).to_s
                    time_end = (Time.now.in_time_zone+1.month).strftime("%Y-%m-%d").to_s
                    sku = product.sku.to_s
                    title = product.title.to_s
                    quantity = product.quantity.to_s
                    costprice = product.costprice.to_s
                    price = product.price.to_s
                    offer_id = product.offer_id.to_s
                    barcode = product.barcode.to_s
                    avito_params = product.avito_param.split('---')
                    cross = avito_params.present? && avito_params.any?{|a| a.include?('cross')} ? 
                                    avito_params.select{|p| p.split(':')[1] if p.split(':')[0] == 'cross'}[0].split(':').last : ''
                    desc = "<p>&#9989; Деталь в наличии</p>
                            <p>&#128194;Артикул: #{sku}</p>
                            <p>&#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134;</p>
                            <p></p>
                            <p>&#128662; Доставка по Москве и МО от 500р</p>
                            <p>&#128350; График работы ПН-ПТ 10:00 – 19:00</p> 
                            <p>&#128666; Отправка в регионы транспортными компаниями ПЭК, Деловые Линии, СДЭК, DPD, Авито Доставка</p> 
                            <p>&#128222; Звоните, пишите, добавляйте товары в избранное, чтобы не потерять!</p>
                            <p></p>
                            <p>&#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134;</p>
                            <p>Кросс номер: #{cross.to_s}</p>
                            <p>#{product.desc.to_s}</p>"
                    contactphone = '7 (499) 110-67-24'
                    region = 'Москва'
                    address = "Россия, Москва, Люблинская 76к2"
                    host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
                    images = product.image_urls.map{|h| host+h[:url]}
                    xml.send(:'Ad') {
                        xml.Id id
                        xml.DateBegin time_begin
                        # xml.DateEnd time_end
                        xml.ListingFee 'Package'
                        xml.AdStatus 'Free'
                        xml.ContactPhone contactphone
                        xml.Region region
                        xml.Address address
                        xml.Title title 
                        xml.Description {xml.cdata(desc)}
                        xml.Price price
                        xml.Category "Запчасти и аксессуары"
                        avito_params.each do |a_p|
                            key = a_p.split(':')[0]
                            value = a_p.split(':')[1]
                            xml.send(key.camelize, value) if key != 'Article'
                        end
                        xml.send(:'Images') {
                                        images.each do |image|
                                            xml.Image("url"=>image)
                                        end
                                        }
                    }
                    if product.variants.present?
                        product.variants.each do |var|
                            if var.images.present?
                                host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
                                var_images = var.image_urls.map{|h| host+h[:url]}
                                sku = var.sku.to_s
                                var_desc = "<p>&#9989; Деталь в наличии</p>
                                            <p>&#128194;Артикул: #{sku}</p>
                                            <p>&#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134;</p>
                                            <p></p>
                                            <p>&#128662; Доставка по Москве и МО от 500р</p>
                                            <p>&#128350; График работы ПН-ПТ 10:00 – 19:00</p> 
                                            <p>&#128666; Отправка в регионы транспортными компаниями ПЭК, Деловые Линии, СДЭК, DPD, Авито Доставка</p> 
                                            <p>&#128222; Звоните, пишите, добавляйте товары в избранное, чтобы не потерять!</p>
                                            <p></p>
                                            <p>&#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134; &#10134;</p>
                                            <p>Кросс номер: #{cross.to_s}</p>
                                            <p>#{var.desc.to_s}</p>"
                                var_time_begin = product.avito_date_begin.present? && var.period.present? ? 
                                                    (product.avito_date_begin + "#{var.period}".to_i.day).strftime("%Y-%m-%dT09:00:00+03:00").to_s : 
                                                    (Time.now.in_time_zone.strftime("%Y-%m-%d %H:%M")).to_s
                            
                                xml.send(:'Ad') {
                                    xml.Id id+"_"+var.id.to_s
                                    xml.DateBegin var_time_begin
                                    # xml.DateEnd time_end
                                    xml.ListingFee 'Package'
                                    xml.AdStatus 'Free'
                                    xml.ContactPhone contactphone
                                    xml.Region region
                                    xml.Address address
                                    xml.Title var.title.to_s 
                                    xml.Description {xml.cdata(var_desc)}
                                    xml.Price price
                                    xml.Category "Запчасти и аксессуары"
                                    avito_params.each do |a_p|
                                        key = a_p.split(':')[0]
                                        value = a_p.split(':')[1]
                                        xml.send(key.camelize, value) if key != 'Article'
                                    end
                                    xml.send(:'Images') {
                                                    var_images.each do |image|
                                                        xml.Image("url"=>image)
                                                    end
                                                    }
                                }
                            end
                        end
                    end
                end			
            }
        }
        
        File.open("#{Rails.public_path}"+"/"+file_name, "w") {|f| f.write(xml.to_xml)}
        puts "Закончили Формируем avito "+"#{Time.zone.now}"
    end
        
end
  