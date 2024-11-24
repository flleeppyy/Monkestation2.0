import { Fragment } from 'inferno';
import { Box, NoticeBox } from '../../components';

export type LobbyNoticesType = (
  | string
  | { TGUI_SAFE?: string | string[]; CHATBOX_SAFE?: string }
)[];

export const LobbyNotices = (props: { notices?: LobbyNoticesType }) => {
  if (!props.notices || props.notices.length === 0) return null;
  const filteredLobbyNotices = props.notices.filter(
    (warning) =>
      typeof warning === 'string' ||
      (typeof warning === 'object' && warning.TGUI_SAFE),
  );

  if (filteredLobbyNotices.length === 0) return null;

  return (
    <>
      {filteredLobbyNotices.map((notice, index) => (
        <NoticeBox danger>
          <>
            {typeof notice === 'string' ? (
              <Box key={index + '_'}>{notice}</Box>
            ) : (
              // Process object with TGUI_SAFE
              <>
                {Array.isArray(notice.TGUI_SAFE)
                  ? notice.TGUI_SAFE.map((notice, index) => (
                      <Box
                        key={index + '__'}
                        dangerouslySetInnerHTML={{ __html: notice }}
                      />
                    ))
                  : notice.TGUI_SAFE && (
                      <Box
                        key={index + '___'}
                        dangerouslySetInnerHTML={{ __html: notice.TGUI_SAFE }}
                      />
                    )}
              </>
            )}
            {index < filteredLobbyNotices.length - 1 && (
              <hr className="solid" />
            )}
          </>
        </NoticeBox>
      ))}
    </>
  );
};

const UI_WARNINGS = [
  [
    {
      TGUI_SAFE: [
        "Monkestation admins are <span class='bold'>NO LONGER</span> accepting appeals for permanent bans until <span class='notice'>January 5th, 2025</span>",
        "Any permanent ban appeals made before said date will be <span class='bold red'>AUTOMATICALLY DENIED!</span>",
        "So don't get caught doing something stupid, ya hear?",
      ],
      CHATBOX_SAFE:
        "<span class='red big'>Monkestation admins are <span class='bold'>NO LONGER</span> accepting appeals for permanent bans until <span class='notice'>January 15th, 2025</span></span><br><hr><span class='yellowteamradio big'>Any permanent ban appeals made before said date will be <span class='bold red'>AUTOMATICALLY DENIED!</span></span><br><span class='big notice'>So don't get caught doing something stupid, ya hear?</span>",
    },
  ],
  // ADD DIVIDER
  'oooga booga.',
  // ADD DIVIDER
  {
    // this is also fine too, it doesnt have to be an array.
    TGUI_SAFE: 'SDLKJDJSDFSDFFGSGSGSGS',
    CHATBOX_SAFE: 'llooOLOLLLOLL',
  },
];
