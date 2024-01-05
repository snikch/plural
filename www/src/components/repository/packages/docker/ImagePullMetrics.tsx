import { useCallback, useMemo, useRef } from 'react'
import { useOutletContext } from 'react-router-dom'
import { Box } from 'grommet'
import moment from 'moment'
import {
  Codeline,
  PageTitle,
  SubTab,
  TabList,
  TabPanel,
} from '@pluralsh/design-system'

import { Graph } from '../../../utils/Graph'

export const DURATIONS = [
  {
    offset: '7d',
    step: '2h',
    label: '7d',
    tick: 'every 12 hours',
  },
  {
    offset: '30d',
    step: '1d',
    label: '30d',
    tick: 'every 2 days',
  },
  {
    offset: '60d',
    step: '1d',
    label: '60d',
    tick: 'every 5 days',
  },
  {
    offset: '120d',
    step: '1d',
    label: '120d',
    tick: 'every 10 day',
  },
]

function RangePicker({ duration, setDuration, tabStateRef }: any) {
  const selectedKey = `${duration.offset}+${duration.step}`

  return (
    <TabList
      stateRef={tabStateRef}
      stateProps={{
        orientation: 'horizontal',
        selectedKey,
        onSelectionChange: (key) => {
          const dur = DURATIONS.find((d) => key === `${d.offset}+${d.step}`)

          if (dur) setDuration(dur)
        },
      }}
    >
      {DURATIONS.map((d) => (
        <SubTab
          key={`${d.offset}+${d.step}`}
          textValue={d.label}
        >
          {d.label}
        </SubTab>
      ))}
    </TabList>
  )
}

export default function ImagePullMetrics() {
  const {
    image: { dockerRepository },
    imageName,
    filter,
    setFilter,
  } = useOutletContext() as any
  const data = useMemo(
    () =>
      dockerRepository.metrics.map(({ tags, values }) => {
        const tag = tags.find(({ name }) => name === 'tag')

        return {
          id: tag ? tag.value : dockerRepository.name,
          data: values.map(({ time, value }) => ({
            x: moment(time).toDate(),
            y: value,
          })),
        }
      }),
    [dockerRepository.metrics, dockerRepository.name]
  )
  const tabStateRef = useRef<any>(null)
  const setDuration = useCallback(
    ({ offset, step, tick }) =>
      setFilter({
        ...filter,
        offset,
        precision: step,
        tick,
      }),
    [filter, setFilter]
  )

  return (
    <Box
      fill
      flex={false}
      gap="small"
    >
      <PageTitle heading="Pull metrics">
        <Codeline
          maxWidth="200px"
          display-desktop-up="none"
        >
          {`docker pull ${imageName}`}
        </Codeline>
      </PageTitle>
      <TabPanel
        stateRef={tabStateRef}
        as={
          <Box
            overflow={{ vertical: 'hidden' }}
            height="350px"
          />
        }
      >
        <RangePicker
          tabStateRef={tabStateRef}
          duration={{ offset: filter.offset, step: filter.precision }}
          setDuration={setDuration}
        />
        <Graph
          data={data}
          precision={filter.precision}
          offset={filter.offset}
          tick={filter.tick}
        />
      </TabPanel>
    </Box>
  )
}
