import { Fragment, useContext, useMemo } from 'react'
import { PageTitle } from '@pluralsh/design-system'
import { Div, P } from 'honorable'
import moment from 'moment'

import RoadmapContext from '../../contexts/RoadmapContext'

import { IssueType } from './types'
import { LABEL_ROADMAP } from './constants'

import RoadmapIssue from './RoadmapIssue'

function RoadmapFeatureRequests() {
  const { pluralIssues, pluralArtifactsIssues } = useContext(RoadmapContext)

  const packs = useMemo(() => {
    const issues = [...pluralIssues, ...pluralArtifactsIssues].filter(issue => issue.labels.includes(LABEL_ROADMAP) && issue.state === 'closed')

    return Object.entries(issues
      .map(issue => ({
        month: moment(issue.createdAt).startOf('month').toISOString(),
        issue,
      }))
      .reduce<Record<string, IssueType[]>>((acc, { month, issue }) => {
        if (!acc[month]) {
          acc[month] = []
        }

        acc[month].push(issue)

        return acc
      }, {}))
      .sort(([monthA], [monthB]) => moment(monthB).diff(monthA))
      .map(([month, issues]) => ({
        month,
        issues,
      }))
  }, [pluralIssues, pluralArtifactsIssues])

  return (
    <>
      <PageTitle heading="Changelog" />
      <Div
        flexGrow={1}
        height="calc(100% - 89px)" // 89px is the title size
        overflowY="auto"
      >
        {packs.map(({ month, issues }) => (
          <Fragment key={month}>
            <P subtitle1>
              {moment(month).format('MMMM YYYY')}
            </P>
            <Div
              marginTop="medium"
              marginBottom="xlarge"
              backgroundColor="fill-one"
              border="1px solid border"
              borderRadius="large"
            >
              {issues.map(issue => (
                <RoadmapIssue
                  key={issue.id}
                  displayAuthor
                  displayProgress
                  issue={issue}
                />
              ))}
            </Div>
          </Fragment>
        ))}
      </Div>
    </>
  )
}

export default RoadmapFeatureRequests