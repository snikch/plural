import { gql } from '@apollo/client'

// TODO: Use virtual scrolling
export const APPLICATIONS_QUERY = gql`
  query Repositories($provider: Provider!, $installed: Boolean = false) {
    repositories(first: 1000, installed: $installed, provider: $provider) {
      edges {
        node {
          id
          name
          description
          private
          icon
          darkIcon
          installation {
            updatedAt
            id
            context
            pingedAt
          }
        }
      }
    }
  }
`

export const FULL_APPLICATIONS_QUERY = gql`
  query Applications($provider: Provider!, $installed: Boolean = false) {
    shellApplications {
      name
      ready
      componentsReady
      components {
        group
        kind
        name
        status
      }
      spec {
        links {
          url
        }
      }
    }
    repositories(first: 1000, installed: $installed, provider: $provider) {
      edges {
        node {
          id
          name
          description
          private
          icon
          darkIcon
          installation {
            updatedAt
            id
            context
            pingedAt
          }
        }
      }
    }
  }
`
