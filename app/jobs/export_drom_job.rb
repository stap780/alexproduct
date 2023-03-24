class ExportDromJob < ApplicationJob
    queue_as :default
  
    def perform
      # Do something later
      Services::Export.drom
    end
  end
  