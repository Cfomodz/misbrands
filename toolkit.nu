# Given a url to a pull request against a repo in our fork network, then apply the diff and make a commit
export def import-pull-request [
  pull_request # Url to a pull request (eg <https://github.com/mkrl/misbrands/pull/86>)
] {
  let pull_request_data = $pull_request
  | parse "{rest}github.com/{user}/{repo}/pull/{pull_request_id}"
  | first
  | http get $"https://api.github.com/repos/($in.user)/($in.repo)/pulls/($in.pull_request_id)"
  let message = $pull_request_data.title
  let user = $pull_request_data.user.login
  let url = $pull_request_data.head.repo.html_url
  let commit_message = $"($message) \(credit @($user)) <($url)>"
  http get $pull_request_data.diff_url | git apply
  git add -A
  git commit -m $commit_message
}
