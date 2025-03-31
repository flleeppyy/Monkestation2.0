import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';

enum CkeyPollEnum {
  PLEXORA_DOWN = -1,
  PLEXORA_CKEYPOLL_FAILED = 0,
  PLEXORA_CKEYPOLL_NOTLINKED,
  PLEXORA_CKEYPOLL_RECORDNOTVALID,
  PLEXORA_CKEYPOLL_LINKED,
  PLEXORA_CKEYPOLL_LINKED_ABSENT,
  PLEXORA_CKEYPOLL_LINKED_BANNED,
  PLEXORA_CKEYPOLL_LINKED_DELETED,
}
interface DiscordVerificationData {
  verification_code: string;
  discord_invite: string;
  discord_details: {
    status: CkeyPollEnum;
    discord_id?: string;
    discord_username?: string;
    discord_displayname?: string;
  };
}

export const DiscordVerification = (props, context) => {
  const { act, data } = useBackend<DiscordVerificationData>();
  const { verification_code, discord_invite, discord_details } = data;

  const getNoticeBox = () => {
    if (!discord_details?.status) {
      return null;
    }

    switch (discord_details?.status as CkeyPollEnum) {
      case CkeyPollEnum.PLEXORA_DOWN:
        return (
          <NoticeBox danger>
            Plexora is currently down, can&apos;t fetch verification data.
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_FAILED:
        return (
          <NoticeBox danger>
            Plexora failed to get info. Discord ID: {discord_details.discord_id}
            .
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_NOTLINKED:
        return (
          <NoticeBox warning>
            Your ckey is not linked to a Discord account.
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_RECORDNOTVALID:
        return <NoticeBox warning>The ckey record is invalid.</NoticeBox>;
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED:
        return (
          <NoticeBox success>
            Your ckey is successfully linked to Discord:{' '}
            {discord_details.discord_username} (
            {discord_details.discord_displayname}) -{' '}
            {discord_details.discord_id}
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED_ABSENT:
        if (
          discord_details.discord_username &&
          discord_details.discord_displayname
        ) {
          return (
            <NoticeBox warning>
              Your linked Discord account is no longer present:{' '}
              {discord_details.discord_username} (
              {discord_details.discord_displayname}) -{' '}
              {discord_details.discord_id}
            </NoticeBox>
          );
        } else {
          return (
            <NoticeBox warning>
              Your linked Discord account is no longer present. Discord ID:{' '}
              {discord_details.discord_id}
            </NoticeBox>
          );
        }
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED_BANNED:
        return (
          <NoticeBox danger>
            Your linked Discord account is banned:{' '}
            {discord_details.discord_username} (
            {discord_details.discord_displayname}) -{' '}
            {discord_details.discord_id}
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED_DELETED:
        return (
          <NoticeBox danger>
            Your linked Discord account has been deleted:{' '}
            {discord_details.discord_username} (
            {discord_details.discord_displayname}) -{' '}
            {discord_details.discord_id}
          </NoticeBox>
        );
      default:
        return null;
    }
  };

  return (
    <Window title="Discord Verification" width={700} height={800}>
      <Window.Content scrollable>
        <Section title="Your Verification Code">
          <Box>
            <Button
              icon="copy"
              onClick={() => navigator.clipboard.writeText(verification_code)}
            >
              Copy to clipboard
            </Button>
          </Box>
          <Box
            mt={1}
            p={1}
            style={{
              wordBreak: 'break-word',
              background: '#444',
              padding: '5px',
            }}
          >
            {verification_code}
          </Box>
        </Section>
        <Section title="Join the Discord">
          <Button icon="paperclip" as="a" href={discord_invite} target="_blank">
            Click to open in your browser
          </Button>
          <Box
            mt={1}
            p={1}
            style={{
              wordBreak: 'break-word',
              background: '#444',
              padding: '5px',
            }}
          >
            <a href={discord_invite}>{discord_invite}</a>
          </Box>
        </Section>

        <Section title="Verification Steps">
          <LabeledList>
            <LabeledList.Item label="Step 1">
              Click &quot;Copy to Clipboard&quot; or manually copy the code
              above.
            </LabeledList.Item>
            <LabeledList.Item label="Step 2">
              Join the Discord server using the invite link above.
            </LabeledList.Item>
            <LabeledList.Item label="Step 3">
              Read the rules and instructions in the Discord server.
            </LabeledList.Item>
            <LabeledList.Item label="Step 4">
              Navigate to <b>#bot-dump</b> and type in <b>/verifydiscord</b>.
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image1.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Step 5">
              Paste your verification code into the code field then hit enter.
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image2.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Step 6">
              Select <b>MRP1 or MRP2</b> from the server dropdown. (It
              doesn&quot;t matter)
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image3.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Step 7">
              After selecting the server, you should be verified and
              reconnected.
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image4.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
