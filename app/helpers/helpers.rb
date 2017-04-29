
module ScoreViewer
  class App
    module Helper
      ## filter
      def filter(rel, controller)
        #keys = filter_keys[controller]
        keys = settings.filter_keys[controller]
        keys.each do |filter|
          rel = rel.where(filter =>params[filter]) if params[filter].present?
        end
        return rel
      end
      
      ## params, query
      def splat_to_params(params)
        return if params[:splat].blank?
        parts = params[:splat].first.split('/')
        parts.each do |part|
          key, value = part.split(/:/)
          params[key.to_sym] = value if value
        end
      end

      def params_to_query(params, controller)
        permitted_keys = [settings.filter_keys[controller], :page].flatten
        query = params.select {|k,v| permitted_keys.include?(k.to_sym) && v.present? }.map {|k, v|
          [k, ERB::Util.url_encode(v.to_s)].join(':')
        }.join('/')
        query += ".#{params[:format]}" if params[:format].present?
        return query
      end
      
      ## utilities
      def output_csv(header, records, filename: "attachement.csv")
        require 'csv'
        content_type 'application/octet-stream'
        attachment filename

        [header.to_csv, records.map {|r| r.to_csv}].flatten.join('')
      end

      def link_to_result_pdf(url)
        return "-" if url.nil?
        icon_url = "http://wwwimages.adobe.com/content/dam/acom/en/legal/images/badges/Adobe_PDF_file_icon_24x24.png"
        link_to(image_tag(icon_url), url, target: "_blank")
      end
      def link_to_skater(skater)
        url = (skater.isu_number.blank?) ? url_for(:skaters, :name, name: skater.name) : url_for(:skaters, :isu_number, isu_number: skater.isu_number)
        link_to(skater.name, url)
      end

      def paginate(records)
        per_page = settings.config[:list][:per_page] || 20
        page = (params[:page].presence || 1).to_i
        records.limit(per_page).offset((page-1)*per_page)
      end
    end  ## module
    helpers Helper
  end ## class
end
