# Helper methods defined here can be accessed in any controller or view in the application

module ScoreViewer
  class App
    module ScoresHelper
      def filter_keys
        [:skater_name, :category, :segment, :nation, :competition_name,
         :element, :component_number, :partial_match,
         :competition_type, :season,
        ]
      end
      
      def filter(rel, keys=nil)
        keys ||= filter_keys
        keys.each do |filter|
          rel = rel.where(filter =>params[filter]) if params[filter].present?
        end
        return rel
      end
      
      def output_csv(header, records, filename: "attachement.csv")
        require 'csv'
        #content_type 'text/plain'
        content_type 'application/octet-stream'
        attachment filename

        [header.to_csv, records.map {|r| r.to_csv}].flatten.join('')
      end

      def splat_to_params(params)
        return if params[:splat].blank?
        parts = params[:splat].first.split('/')
        parts.each do |part|
          key, value = part.split(/:/)
          params[key.to_sym] = value if value
        end
      end

      def params_to_query(params) # , keys)
        query = params.select {|k,v| filter_keys.include?(k.to_sym) && v.present? }.map {|k, v|
          [k, ERB::Util.url_encode(v.to_s)].join(':')
        }.join('/')
        query += ".#{params[:format]}" if params[:format].present?
        return query
      end
      def score_filter_forms
        [
         [:skater_name, Score.select(:skater_name).distinct.order(:skater_name).map(&:skater_name)],
         [:category, ['MEN', 'LADIES']],
         [:segment, ['SHORT PROGRAM', 'FREE SKATING']],
         [:nation, Score.select(:nation).distinct.to_a.map(&:nation)],
         [:competition_name, Score.select(:competition_name).distinct.to_a.map(&:competition_name)],
         [:format, ['html', 'csv']],
        ]
      end
      def link_to_result_pdf(url)
        link_to(image_tag("http://wwwimages.adobe.com/content/dam/acom/en/legal/images/badges/Adobe_PDF_file_icon_24x24.png"), url, target: "_blank")
      end
    end ## module
    helpers ScoresHelper
  end  # class
end
