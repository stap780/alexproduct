class ImportProductJob < ApplicationJob
  queue_as :import_product

  def perform
    # Do something later
    ProductImport.product
  end
end
