
module ScoreViewer
  class App
    module Helper
      ## filter
      def filter_keys
        {
          scores: [:skater_name, :category, :segment, :nation, :competition_name,],
          skaters: [:category, :nation],
          competitions: [:competition_type, :season],
          elements: [:element, :partial_match, :skater_name, :category, :segment, :nation, :competition_name,],
          components: [:component_number, :skater_name, :category, :segment, :nation, :competition_name,],
        }
      end
      
      def filter(rel, controller)
        keys = filter_keys[controller]
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
        permitted_keys = [filter_keys[controller], :page].flatten
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
        link_to(image_tag("http://wwwimages.adobe.com/content/dam/acom/en/legal/images/badges/Adobe_PDF_file_icon_24x24.png"), url, target: "_blank")
      end
    end  ## module
    helpers Helper
  end ## class
end