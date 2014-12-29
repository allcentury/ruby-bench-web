class ReposController < ApplicationController
  # ZOMG too much logic here and we really need to clean this up.
  # ActiveRecord queries are taking wayyy tooo long.
  def show
    organization = Organization.find_by_name(params[:organization_name]) || not_found
    @repo = organization.repos.find_by_name(params[:repo_name])
    @commits = @repo.commits
    @form_result_types = params[:result_types].try(:sort)

    benchmark_runs = BenchmarkRun.where(
      initiator_id: @commits.map(&:id),
      initiator_type: 'Commit'
    ).preload(:initiator)

    @result_types = benchmark_runs.pluck(:category).uniq.sort.group_by do |category|
      category =~ /\A([^_]+)_/
      $1
    end

    commits_sha1s ||= ['Commit SHA1']
    commits_data ||= {}

    benchmark_runs.where(category: @form_result_types).each do |benchmark_run|
      commits_sha1s << "
        Commit: #{benchmark_run.initiator.sha1[0..6]}<br>
        Commit Date: #{benchmark_run.initiator.created_at}
      ".squish

      benchmark_run.result.each do |key, value|
        commits_data[benchmark_run.category] ||= {}
        commits_data[benchmark_run.category][:unit] ||= benchmark_run.unit
        commits_data[benchmark_run.category][:script_url] ||= benchmark_run.script_url
        commits_data[benchmark_run.category][:category] ||= benchmark_run.category
        commits_data[benchmark_run.category][key] ||= [key]
        commits_data[benchmark_run.category][key] << value
      end
    end

    @graphs_columns = build_graphs_columns(commits_sha1s, commits_data)
  end

  private

  def build_graphs_columns(commits_sha1s, commits_data)
    if !commits_data.empty?
      commits_data.map do |result_type, result_data|
        graphs_columns = [commits_sha1s]

        result_data.map do |_, value|
          graphs_columns << value
        end

        graphs_columns
      end
    end
  end
end
