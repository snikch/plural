import React, { useState } from 'react'
import { useMutation } from 'react-apollo'
import { Button, SecondaryButton } from 'forge-core'
import { Box, Text, FormField, TextInput } from 'grommet'
import { ACTIONS } from './types'
import { CREATE_WEBHOOK, WEBHOOKS_Q } from './queries'
import { appendConnection, updateCache } from '../../utils/graphql'

export function ActionTab({action, onClick}) {
  return (
    <Box key={action} background='light-3' round='xsmall' pad={{vertical: '2px', horizontal: 'small'}}
         hoverIndicator='light-5' onClick={onClick}>
      <Text size='small' weight={500}>{action}</Text>
    </Box>
  )
}

export function ActionInput({actions, setActions}) {
  const [value, setValue] = useState('')

  return (
    <Box flex={false} fill='horizontal'>
      <Box flex={false} fill='horizontal' direction='row' gap='small' align='center'>
        <Box fill='horizontal'>
          <TextInput
            plain
            value={value}
            placeholder='add an action for this webhook'
            onSelect={({suggestion: action}) => setActions([...actions, action])}
            suggestions={ACTIONS.filter((action) => action.includes(value))}
            onChange={({target: {value}}) => setValue(value)} />
        </Box>
        <SecondaryButton label='Add' onClick={() => setActions([...actions, value])} />
      </Box>
      <Box flex={false} direction='row' gap='xxsmall' align='center' wrap>
        {actions.map((action) => (
          <ActionTab key={action} action={action} onClick={() => setActions(actions.filter((a) => a !== action))} />
        ))}
      </Box>
    </Box>
  )
}

export function CreateWebhook({cancel}) {
  const [attributes, setAttributes] = useState({name: '', url: '', actions: ['incident.create']})
  const [mutation, {loading}] = useMutation(CREATE_WEBHOOK, {
    variables: {attributes}, 
    update: (cache, { data: { createIntegrationWebhook }}) => updateCache(cache, {
      query: WEBHOOKS_Q,
      update: (prev) => appendConnection(prev, createIntegrationWebhook, 'IntegrationWebhook', 'integrationWebhooks')
    }),
    onCompleted: cancel
  })

  return (
    <Box pad='small'>
      <FormField label='name'>
        <TextInput 
          placeholder='name for the webhook' 
          value={attributes.name} 
          onChange={({target: {value}}) => setAttributes({...attributes, name: value})} />
      </FormField>
      <FormField label='url'>
        <TextInput 
          placeholder='url to deliver to' 
          value={attributes.url} 
          onChange={({target: {value}}) => setAttributes({...attributes, url: value})} />
      </FormField>
      <ActionInput actions={attributes.actions} setActions={(actions) => setAttributes({...attributes, actions})} />
      <Box direction='row' align='center' justify='end' gap='xsmall'>
        <SecondaryButton label='Cancel' onClick={cancel} />
        <Button label='Create' onClick={mutation} loading={loading} />
      </Box>
    </Box>
  )
}