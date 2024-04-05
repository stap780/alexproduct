class ExportDrom < ApplicationService

    def call
    puts "Формируем drom #{Time.now}"  
    file_name =  "drom.xml"  
    products = Product.not_nill.with_images
    xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml|	
        xml.doc.create_internal_subset(
        'yml_catalog', nil, "shops.dtd"
        )
        xml.send(:'yml_catalog', :date => "#{Time.now.in_time_zone.strftime("%Y-%m-%d %H:%M")}") {
        xml.shop {
            xml.currencies {
            xml.send(:'currency', :id => "RUR", :rate => "1.0")
            }
            xml.offers {
                products.each do |product|
                    id = product.id.to_s
                    title = product.title.to_s
                    price = product.price.to_s
                    
                    host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
                    images = product.image_urls.map{|h| host+h[:url]}
                    sku = product.sku.to_s
                    avito_params = product.avito_param.split('---')
                    cross = avito_params.present? && avito_params.any?{|a| a.include?('cross')} ? 
                                    avito_params.select{|p| p.split(':')[1] if p.split(':')[0] == 'cross'}[0].split(':').last : ''
                    vendorCode = avito_params.present? && avito_params.any?{|a| a.include?('oem')} ?
                                    avito_params.select{|p| p.split(':')[1] if p.split(':')[0] == 'oem'}[0].split(':').last : ''
                    desc = "<p>Обмен и возврат в течение 14 дней</p>
                            <p>Артикул #{sku}</p>
                            <p>Номер запчасти #{vendorCode}</p>
                            <p>Количество 1</p>
                            <p>Доставка по Москве и МО от 500р.</p>
                            <p>Доставка в регионы транспортной компанией - СДЭК р!</p>
                            <p>Адрес: г.Москва, Москва, Люблинская ул., 76к2</p>
                            <p>Звоните перед выездом для уточнения наличия</p>
                            <p> Аналоги - #{cross.to_s}</p>
                            <p>#{product.desc.to_s}</p>"

                    
                    xml.send(:'offer', :id => "#{id}.to_s") {
                        xml.price price
                        xml.currencyId "RUR".to_s
                        images.each do |image|
                        xml.picture image
                        end
                        xml.store "true"
                        xml.pickup "true"
                        xml.delivery "true"
                        xml.name title 
                        xml.vendorCode vendorCode
                        xml.condition 'Новое'
                        xml.description {xml.cdata(desc)}
                        }
                    if product.variants.present?
                        product.variants.each do |var|
                            if var.images.present?
                                host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
                                var_images = var.image_urls.map{|h| host+h[:url]}
                                sku = var.sku.to_s
                                var_desc = "<p>Обмен и возврат в течение 14 дней</p>
                                <p>Артикул #{sku}</p>
                                <p>Номер запчасти #{vendorCode}</p>
                                <p>Количество 1</p>
                                <p>Доставка по Москве и МО от 500р.</p>
                                <p>Доставка в регионы транспортной компанией - СДЭК р!</p>
                                <p>Адрес: г.Москва, Москва, Люблинская ул., 76к2</p>
                                <p>Звоните перед выездом для уточнения наличия</p>
                                <p> Аналоги - #{cross.to_s}</p>
                                <p>#{var.desc.to_s}</p>"

                                xml.send(:'offer', :id => "#{id}.to_s_#{var.id}.to_s") {
                                    xml.price price
                                    xml.currencyId "RUR".to_s
                                    images.each do |image|
                                    xml.picture image
                                    end
                                    xml.store "true"
                                    xml.pickup "true"
                                    xml.delivery "true"
                                    xml.name var.title 
                                    xml.vendorCode vendorCode
                                    xml.condition 'Новое'
                                    xml.description {xml.cdata(var_desc)}
                                    }
                            end
                        end
                    end
                end			
            }
        }
        } 
        }
        
    File.open("#{Rails.public_path}"+"/"+file_name, "w")	{|f| f.write(xml.to_xml)}
    puts "Закончили Формируем drom #{Time.now}"
    end

end
