require 'stringio'

class ScmService
  attr_accessor :client

  def initialize(client)
    @client = client
  end

  def create_pull_request(request)
    target_dir = request['target_dir']

    puts "Action: pull_request"
    puts "Target dir: #{target_dir}"

    log = StringIO.new
    repo = Git::Repository.new(target_dir, log)

    repository  = self.class.github_repository(repo.url)
    branch_name = repo.branch_name
    base        = 'master'
    head        = branch_name
    issue_id    = branch_name.to_i
    body        = "This PR implements ##{issue_id}"

    return unless repo.nothing_to_commit?

    if repo.push
      issue = client.issue(repository, issue_id)
      response = client.create_pull_request(
        repository, base, head, issue['title'], body)

      puts "head: #{branch_name}"
      puts "repository: #{repository}"
    end
  rescue Octokit::UnprocessableEntity => error
  end

  def self.github_repository(url)
    match = /git@(?<hostname>.*):(?<repository>.*).git/.match(url)
    match && match["repository"]
  end
end