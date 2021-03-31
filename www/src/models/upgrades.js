import gql from 'graphql-tag'
import { RepoFragment } from './repo'

export const UpgradeQueueFragment = gql`
  fragment UpgradeQueueFragment on UpgradeQueue {
    id
    acked
  }
`

export const UpgradeFragment = gql`
  fragment UpgradeFragment on Upgrade {
    id
    message
    repository { ...RepoFragment }
    insertedAt
  }
  ${RepoFragment}
`