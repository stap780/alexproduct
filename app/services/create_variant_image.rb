class CreateVariantImage < ApplicationService

    def initialize(variant_id, index, image_ids)
    @variant = Variant.find_by_id(variant_id)
    @index = index
    @error_message = false
    @image_ids = image_ids
    end

    def call
        result = create_image
        if @error_message
            false
        else
            true
        end
    end

    private

    def create_image

        image_convert_rules = {
                                1 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92"},
                                2 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92"},
                                3 => {"-crop" => "900x900+50+200"},
                                4 => {"-crop" => "999x999+100+100"},
                                5 => {"-crop" => "999x999+120+120"},
                                6 => {"-crop" => "980x980+130+130"},
                                7 => {"-brightness-contrast" => "10x5"},
                                8 => {"-unsharp" => "95%"},
                                9 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "900x900+50+200"},
                                10 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+100+100"}
                                # 11 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+120+120"},
                                # 12 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "980x980+130+130"},
                                # 13 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-brightness-contrast" => "10x5"},
                                # 14 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-unsharp" => "95%"},
                                # 15 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "900x900+50+200"},
                                # 16 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+100+100"},
                                # 17 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+120+120"},
                                # 18 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "980x980+130+130"},
                                # 19 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-brightness-contrast" => "10x5"},
                                # 20 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-unsharp" => "95%"},
                                # 21 => {"-crop" => "900x900+50+200","-brightness-contrast" => "10x5"},
                                # 22 => {"-crop" => "900x900+50+200","-unsharp" => "95%"},
                                # 23 => {"-crop" => "999x999+100+100","-brightness-contrast" => "10x5"},
                                # 24 => {"-crop" => "999x999+100+100","-unsharp" => "95%"},
                                # 25 => {"-crop" => "999x999+120+120","-brightness-contrast" => "10x5"},
                                # 26 => {"-crop" => "999x999+120+120","-unsharp" => "95%"},
                                # 27 => {"-crop" => "980x980+130+130","-brightness-contrast" => "10x5"},
                                # 28 => {"-crop" => "980x980+130+130","-unsharp" => "95%"},
                                # 29 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "980x980+130+130","-unsharp" => "95%"}
                            }
        rule = image_convert_rules[@index+1]
        if rule.present?
            options = rule
            remove_images
            create_convert_images(options)
        else
            @error_message = true
        end
    end
    def remove_images
        if @variant.images.present?
            @variant.images.each do |image|
                ActiveStorage::Attachment.find(image.id).destroy
            end
        end
    end

    def create_convert_images(options)
        @image_ids.each do |im_id|
            pi = ActiveStorage::Attachment.find(im_id)
            im_service = ConvertImage.new(pi,nil,nil,options)
            im_service.multi_changes_for_jpg
            # im_service.resize
            # puts "im_service => "+im_service.inspect.to_s
            temp_image = im_service.temp_image_path
            filename = pi.filename.to_s+"_"+@variant.id.to_s
            @variant.images.attach(io: File.open(temp_image), filename: filename)
            im_service.close
        end
    end

end