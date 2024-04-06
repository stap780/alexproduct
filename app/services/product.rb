# class Services::Product

#     def self.create_variants(product)

#         image_convert_rules = {
#             1 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92"},
#             2 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92"},
#             3 => {"-crop" => "900x900+50+200"},
#             4 => {"-crop" => "999x999+100+100"},
#             5 => {"-crop" => "999x999+120+120"},
#             6 => {"-crop" => "980x980+130+130"},
#             7 => {"-brightness-contrast" => "10x5"},
#             8 => {"-unsharp" => "95%"},
#             9 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "900x900+50+200"},
#             10 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+100+100"},
#             11 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+120+120"},
#             12 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "980x980+130+130"},
#             13 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-brightness-contrast" => "10x5"},
#             14 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-unsharp" => "95%"},
#             15 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "900x900+50+200"},
#             16 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+100+100"},
#             17 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "999x999+120+120"},
#             18 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-crop" => "980x980+130+130"},
#             19 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-brightness-contrast" => "10x5"},
#             20 => {"-rotate" => "-2", "-background" => "transparent", "-quality" => "92","-unsharp" => "95%"},
#             21 => {"-crop" => "900x900+50+200","-brightness-contrast" => "10x5"},
#             22 => {"-crop" => "900x900+50+200","-unsharp" => "95%"},
#             23 => {"-crop" => "999x999+100+100","-brightness-contrast" => "10x5"},
#             24 => {"-crop" => "999x999+100+100","-unsharp" => "95%"},
#             25 => {"-crop" => "999x999+120+120","-brightness-contrast" => "10x5"},
#             26 => {"-crop" => "999x999+120+120","-unsharp" => "95%"},
#             27 => {"-crop" => "980x980+130+130","-brightness-contrast" => "10x5"},
#             28 => {"-crop" => "980x980+130+130","-unsharp" => "95%"},
#             29 => {"-rotate" => "2", "-background" => "transparent", "-quality" => "92","-crop" => "980x980+130+130","-unsharp" => "95%"}
#         }

#         var_count = 29

#         if product.variants.size < var_count
#             #create variants with images
#             start_count = product.variants.size
#             calc_loop = var_count-start_count
#             for a in 1..calc_loop do
#                 var = product.variants.create!(sku: product.sku, title: product.title, desc: product.desc, period: start_count+a)
#             end
#         end
#         if product.variants.present?
#             puts "===product.variants.present==="
#             product.variants.order(:id).each_with_index do |variant, index|
#                 if variant.present?
#                     puts "===variant.present create_convert_images ==="
#                     options = image_convert_rules[index+1]
#                     variant.create_convert_images(options)
#                 end
#             end
#         end
#     end
    

# end