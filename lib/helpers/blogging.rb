require 'time'

def grouped_articles
  sorted_articles.group_by do |a|
    [ Time.parse(a[:created_at]).strftime("%B"), Time.parse(a[:created_at]).year ]
  end.sort.reverse
end