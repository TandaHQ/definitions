require_relative 'error'

module Definitions
  module Validation
    class Month
      def call(months)
        raise Errors::NoMonths.new("Months is required, received: '#{months}'") if months.nil? || months.empty?

        months.each do |month, month_defs|
          raise Errors::InvalidMonth.new("All months must be an integer, received: #{months}") unless month.is_a?(Integer)
          raise Errors::InvalidMonth.new("All months must be between 0 and 12, received: #{months}") if month < 0 || month > 12

          month_defs.each do |month_def|
            raise Errors::InvalidMonth.new("All months must have a name, received: #{months}") if month_def['name'].nil? || month_def['name'].empty?
            raise Errors::InvalidRegions.new("A month must contain at least one region, received: #{months}") if month_def['regions'].nil? || month_def['regions'].empty?
            month_def['regions'].each do |region|
              raise Errors::InvalidRegions.new("A month must contain at least one region, received: #{months}") if region.nil? || region.empty?
            end

            # Validate that each holiday has at least one date specification
            validate_date_specification!(month_def)
          end
        end

        true
      end

      private

      def validate_date_specification!(month_def)
        has_mday = month_def.key?('mday') && !month_def['mday'].nil?
        has_wday = month_def.key?('wday') && !month_def['wday'].nil?
        has_week = month_def.key?('week') && !month_def['week'].nil?
        has_function = month_def.key?('function') && !month_def['function'].nil? && !month_def['function'].empty?

        holiday_name = month_def['name'] || 'Unknown Holiday'

        # If wday is specified, week must also be specified (and vice versa)
        if (has_wday && !has_week) || (!has_wday && has_week)
          raise Errors::MissingDateSpecification.new(
            "Holiday '#{holiday_name}' with 'wday' must also have 'week' attribute (and vice versa)"
          )
        end

        # Must have either mday, function, or both wday AND week
        valid_date_spec = has_mday || has_function || (has_wday && has_week)

        unless valid_date_spec
          raise Errors::MissingDateSpecification.new(
            "Holiday '#{holiday_name}' must have either 'mday', 'function', or both 'wday' and 'week' attributes to specify the date"
          )
        end
      end
    end
  end
end
