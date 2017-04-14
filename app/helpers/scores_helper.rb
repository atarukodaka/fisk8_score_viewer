# Helper methods defined here can be accessed in any controller or view in the application

module ScoreViewer
  class App
    module ScoresHelper
      # def simple_helper_method
      # ...
      # end

      def max_pages(rel, limit)
        ((rel.count - 1) / limit).to_i + 1
      end

      def select_tag_kept(tag, options: [], selected: nil)
        select_tag(tag, options: options, selected: options.include?(selected) ? selected : '-')
      end
    end

    helpers ScoresHelper
  end
end
