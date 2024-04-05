class ExportDromJob < ApplicationJob
    queue_as :export_drom
  
    def perform
      # Do something later
      ExportDrom.call
    end
  end
  