import { useBackend, useLocalState } from '../backend';
import { Section, Button, Box, Flex, TextArea, Stack } from '../components';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';
import { createRef } from 'inferno';
import { Component } from 'inferno';
import { BooleanLike } from 'common/react';

interface TicketData {
  is_admin: BooleanLike;
  name: string;
  id: string;
  admin: string | null;
  is_resolved: BooleanLike;
  initiator_key_name: string;
  opened_at: string;

  has_client: BooleanLike;
  has_mob: BooleanLike;
  role: string;
  antag: string | null;

  location: string;
  log: Array<{
    text: string;
    time: string;
    ckey: string;
  }>;

  related_tickets: {
    id: string;
    title: string;
  }[];
}

export const TicketPanel = (props) => {
  const { act, data } = useBackend<TicketData>();

  const buttons = [
    [
      {
        name: '',
        act: 'adminmoreinfo',
        icon: 'question',
        disabled: !data.has_mob,
      },
      {
        name: 'PP',
        act: 'PP',
        icon: 'user',
        disabled: !data.has_mob,
      },
      {
        name: 'VV',
        act: 'VV',
        icon: 'cog',
        disabled: !data.has_mob,
      },
      {
        name: 'FLW',
        act: 'FLW',
        icon: 'arrow-up',
        disabled: !data.has_mob,
      },
      {
        name: 'TP',
        act: 'TP',
        icon: 'book-dead',
        disabled: !data.has_mob,
      },
      {
        name: 'Logs',
        act: 'Logs',
        icon: 'file',
        disabled: !data.has_mob,
      },
      {
        name: 'Smite',
        act: 'Smite',
        icon: 'bolt',
        disabled: !data.has_mob,
      },
    ],
    [
      {
        name: 'Notes',
        act: 'Notes',
        icon: 'paperclip',
      },
      {
        name: 'Claim',
        act: 'Administer',
        icon: 'folder-open',
      },
      {
        name: 'Popup',
        act: 'popup',
        icon: 'window-restore',
      },
      {
        name: 'Reject',
        act: 'Reject',
        icon: 'ban',
      },
      {
        name: data.is_resolved ? 'Reopen' : 'Resolve',
        act: data.is_resolved ? 'Reopen' : 'Resolve',
        icon: 'check',
      },
    ],
    [
      {
        name: 'IC',
        act: 'IC',
        icon: 'male',
        disabled: !data.has_client,
      },
      {
        name: 'MHelp',
        act: 'MHelp',
        icon: 'info',
        disabled: !data.has_client,
      },
      {
        name: 'Close',
        act: 'Close',
        icon: 'close',
      },
      {
        name: 'Replay',
        act: 'Replay',
        icon: 'rotate-right',
      },
    ],
  ];
  if (data.is_admin) {
    return (
      <Window
        theme="admintickets"
        title={`Ticket Viewer - #${data.id}`}
        width={1200}
        height={700}
        resizable
      >
        <Window.Content>
          <Stack horizontal fill>
            <Stack.Item width="65%">
              <Stack vertical fill>
                <Section
                  title={`Ticket #${data.id} - ${data.initiator_key_name}: ${data.name}`}
                  // style={{
                  //   fontSize: '1.25em',
                  // }}
                >
                  <span>
                    <span class={data.is_resolved ? 'color-good' : 'color-bad'}>
                      Is{data.is_resolved ? '' : ' not'} resolved
                    </span>
                    <br />
                    Assigned Admin: <b>{data.admin || 'Unassigned'}</b>
                    <br />
                    {data.opened_at}
                  </span>
                  <Section>
                    Job: <b>{data.role}</b> <br />
                    Antag: <b>{data.antag || 'No'}</b>
                    <br />
                    Location: <b>{data.location}</b>
                  </Section>
                  <Section>
                    {buttons.map((button_row, i) => (
                      <Flex key={i} direction="row">
                        {button_row.map((button) => (
                          <Flex.Item key={button.act} grow={1}>
                            <Button
                              fluid
                              m="2.5px"
                              icon={button.icon}
                              disabled={button.disabled}
                              onClick={(
                                (val) => () =>
                                  act(val)
                              )(button.act)}
                            >
                              {button.name}
                            </Button>
                          </Flex.Item>
                        ))}
                      </Flex>
                    ))}
                  </Section>
                </Section>
                <Stack.Item grow={1} height="100%">
                  <Section title="Event log" fill scrollable>
                    {data.log.map((entry) => (
                      <Box key={entry.time} m="2px">
                        {entry.time} - <b>{entry.ckey}</b> -{' '}
                        {decodeHtmlEntities(entry.text)}
                      </Box>
                    ))}
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item width="35%">
              <TicketMessages ticket={data} title="Messages" />
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window title="Ticket Viewer" width={700} height={700} resizable>
      <Window.Content scrollable>
        <TicketMessages title={data.name} ticket={data} showTicketLog />
      </Window.Content>
    </Window>
  );
};

interface TicketMessagesProps {
  ticket: TicketData;
  title: string;
  showTicketLog?: boolean;
}

interface TicketMessagesState {
  message: string;
}

export class TicketMessages extends Component<
  TicketMessagesProps,
  TicketMessagesState
> {
  textareaRef = createRef<HTMLTextAreaElement>();
  act = useBackend().act;

  constructor(props: TicketMessagesProps) {
    super(props);
    this.state = {
      message: '',
    };
  }

  handleInput = (_e: Event, value: string) => {
    this.setState({ message: value });
    this.handleCtrlEnter(_e as KeyboardEvent, value);
  };

  handleCtrlEnter = (e: KeyboardEvent, value: string) => {
    if (e.key === 'Enter' && e.ctrlKey) {
      e.preventDefault();

      this.act('send_message', { message: value });
      this.setState({ message: '' });

      if (this.textareaRef.current) {
        this.textareaRef.current.focus();
      }
    }
  };

  handleSendButton = () => {
    if (!this.state) return;
    const { message } = this.state;

    this.act('send_message', { message });
    this.setState({ message: '' });

    if (this.textareaRef.current) {
      this.textareaRef.current.focus();
    }
  };

  render() {
    const { ticket, title, showTicketLog } = this.props;
    const { message } = this.state!;

    return (
      <Section lineHeight={1.25} title={title}>
        {!!showTicketLog &&
          ticket.log.map((entry) => (
            <Box key={entry.time} m="2px">
              {entry.time} - <b>{entry.ckey}</b> -{' '}
              {decodeHtmlEntities(entry.text)}
            </Box>
          ))}
        <TextArea
          fluid
          innerRef={this.textareaRef}
          value={message}
          placeholder="Enter your message (Ctrl+Enter to send)"
          className="replybox"
          resize="vertical"
          onInput={this.handleInput}
          height="350px"
        />

        <Button mt="5px" onClick={this.handleSendButton}>
          Send Message
        </Button>

        {ticket.related_tickets.length > 0 && ticket.is_admin && (
          <Section title="Related Tickets">
            {ticket.related_tickets.map((related) => (
              <Box key={related.id} m="2px">
                <a
                  onclick={(e) => {
                    e.preventDefault();
                    this.act('open_ticket', {
                      ticket_id: related.id,
                    });
                  }}
                >
                  <b>#{related.id}</b>
                </a>
                : {related.title}
              </Box>
            ))}
          </Section>
        )}
      </Section>
    );
  }
}
