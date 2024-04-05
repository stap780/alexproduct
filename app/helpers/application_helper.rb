module ApplicationHelper

    def flash_class(level)
        case level
        when "info" then "alert alert-info"
        when "notice", "success" then "alert alert-success"
        when "error" then "alert alert-danger"
        when "alert" then "alert alert-warning"
        end
    end
    
    def bs_will_paginate(collection = nil, options = {})
        options, collection = collection, nil if collection.is_a? Hash
        options = options.merge(
            renderer: BootstrapPaginateRenderer, # ApplicationHelper::LinkRenderer,
            previous_label: "&laquo;",
            next_label: "&raquo;"
        )
        will_paginate(collection) #will_paginate(collection, options)
    end

    def div_check_box_tag_all
        content_tag :div, class: "col-1 d-flex self-content-start" do
          check_box_tag("selectAll", "selectAll", class: "checkboxes form-check-input", data: {selectall_target: "checkboxAll", action: "change->selectall#toggleChildren"})
        end
    end
    
    def prepend_flash
        turbo_stream.prepend "our_flash", partial: "shared/flash"
    end
    

    def false_icon
        '<i class="bi bi-x-circle"></i>'.html_safe
    end

    def more_icon
        '<i class="bi bi-three-dots"></i>'.html_safe
      end
    
    def download_icon
    '<i class="bi bi-cloud-arrow-down"></i>'.html_safe
    end

    def add_icon
    "<i class='bi bi-plus'></i> #{t("add")}".html_safe
    end

    def play_icon
    '<i class="bi bi-play"></i>'.html_safe
    end

    def edit_icon
    '<i class="bi bi-pencil"></i>'.html_safe
    end

    def trash_icon
    '<i class="bi bi-trash3"></i>'.html_safe
    end
end
