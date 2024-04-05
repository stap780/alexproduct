class ExportAvitoJob < ApplicationJob
  queue_as :export_avito

  def perform
    # Do something later
    ExportAvito.call
  end
end
