namespace :data do
  desc 'Finds duplicate responses'
  task duplicate: :environment do
    class Hash
      # @param [Hash] other another hash
      # @returns [Hash] a hash of differences between this and another hash
      # @see http://stackoverflow.com/a/7178108
      def diff(other)
        set = keys + other.keys
        set.uniq.each_with_object({}) do |key,memo|
          old_value = self[key]
          new_value = other[key]
          unless old_value == new_value
            memo[key] = if Hash === old_value && Hash === new_value
              old_value.diff new_value
            else
              [old_value, new_value]
            end
          end
        end
      end
    end

    class Fixnum
      def factorial
        (2..self).reduce(:*)
      end

      def combinations(r)
        self.factorial / (r.factorial * (self - r).factorial)
      end
    end

    class Response
      EXCLUDE_KEYS = ['_id', 'initialized_at', 'created_at', 'updated_at']

      # @param [Response] other another response
      # @returns [Hash] a hash of differences between this and another response
      def diff(other)
        attributes.except(*EXCLUDE_KEYS).diff other.attributes.except(*EXCLUDE_KEYS)
      end
    end

    if ENV['ID'].blank?
      abort 'Usage: bundle exec rake data:clean ID=47cc67093475061e3d95369d # Questionnaire ID'
    end

    responses = Questionnaire.find(ENV['ID']).responses.to_a
    progressbar = ProgressBar.create format: '%a |%B| %p%% %e', length: 80, smoothing: 0.5, total: responses.size.combinations(2)
    nonpersonal = %w(subscribe newletter answers)

    json = []
    (responses.size - 2).downto(0).each do |i|
      a = responses[i]

      responses[i + 1..-1].each_with_index do |b,j|
        progressbar.increment
        difference = a.diff b
        fragment = [a.id.to_s, b.id.to_s, difference.size, difference]

        # Destroy duplicates, e.g.:
        # * all differences are non-personal
        case difference.size
        when 0
          b.destroy
          responses.delete_at i + j + 1
        when 1, 2
          if difference.keys.all?{|key| nonpersonal.include? key}
            b.destroy
            responses.delete_at i + j + 1
          else
            # @todo
            json << fragment
          end
        else
          # @todo
          json << fragment
        end
      end
    end
    File.open(Rails.root.join('tmp', 'duplicates.json'), 'w'){|f| f.write MultiJson.dump json}
  end

  # @note If we need to be more sophisticated, we can run non-numeric values through a spam filter.
  desc 'Finds spam responses'
  task spam: :environment do
    class Hash
      # @return [Hash] spam key-value pairs
      def spam
        spam = {}
        each do |k,v|
          if Hash === v || Array === v
            output = v.spam
            spam[k] = output unless output.empty?
          elsif v.to_s[/http|href|src/]
            spam[k] = v
          end
        end
        spam
      end
    end

    # @return [Array] spam values
    class Array
      def spam
        spam = []
        each do |v|
          if Hash === v || Array === v
            output = v.spam
            spam << output unless output.empty?
          elsif v.to_s[/http|href|src/]
            spam << v
          end
        end
        spam
      end
    end

    def puts_recursive_hash(spam, offset = 0)
      spam.each do |k,v|
        print ' ' * offset
        if Hash === v
          puts "#{k}"
          puts_recursive_hash v, offset + 2
        elsif Array === v
          puts "#{k}"
          puts_recursive_array v, offset + 2
        else
          puts "#{k.ljust(24)} #{v.gsub(/[[:space:]]/, ' ')}"
        end
      end
    end

    def puts_recursive_array(spam, offset = 0)
      spam.each do |v|
        if Hash === v
          puts_recursive_hash v, offset + 2
        elsif Array === v
          puts_recursive_array v, offset + 2
        else
          print ' ' * offset
          puts v.gsub(/[[:space:]]/, ' ')
        end
      end
    end

    if ENV['ID'].blank?
      abort 'Usage: bundle exec rake data:clean ID=47cc67093475061e3d95369d # Questionnaire ID'
    end

    responses = Questionnaire.find(ENV['ID']).responses.to_a

    # If we process items in-order with #each_with_index, #delete_at will cause
    # items to be skipped. If we process items in reverse order, deleted items
    # will have already been processed.
    (responses.size - 1).downto(0).each do |i|
      response = responses[i]
      spam = response.attributes.spam

      unless spam.empty?
        puts_recursive_hash spam
        puts "Is this spam? (y/n)"
        if STDIN.gets == "y\n"
          response.destroy
          puts "Deleted #{response.id}\n"
        end
      end
    end
  end
end
