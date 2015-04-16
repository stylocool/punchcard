module ActiveAdmin
  module Views
    class Footer < Component

      def build
        super :id => "footer"
        super :style => "text-align: left;"

        div do
          small "Powered by J-Solutions"
        end
      end

    end
  end
end