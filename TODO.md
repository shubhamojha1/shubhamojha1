# Future work

## Scale the OSS contribution tracker

- [ ] Before the contribution history approaches 100 results, paginate every
  GitHub Search API request and store all results the API makes available.
- [ ] Generate a blocklist-filtered `OSS_CONTRIBUTIONS.md` archive containing
  every eligible PR, grouped by GitHub organization or repository owner.
- [ ] Keep the profile README concise by showing eligible contribution counts
  and only the latest three to five PRs per organization, with a link to the
  archive.
- [ ] Extend the integration test with more than 100 fixture PRs and verify that
  pagination, deduplication, blocklisting, organization grouping, and README
  limits work together.
