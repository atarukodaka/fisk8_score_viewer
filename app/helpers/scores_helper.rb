# Helper methods defined here can be accessed in any controller or view in the application

module ScoreViewer
  class App
    module ScoresHelper
      # def simple_helper_method
      # ...
      # end

      def max_pages(size, limit)
        ((size - 1) / limit).to_i + 1
      end

      def select_tag_kept(tag, options: [], selected: nil)
        select_tag(tag, options: options, selected: options.include?(selected) ? selected : '-')
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

      def params_to_query(params, keys)
        ar = []
        keys.map do |key|
          next if params[key].blank?
          ar << [key, params[key]].join(':')
        end
        ar.join('/')
      end
    end ## module
    helpers ScoresHelper
  end  # class
end
