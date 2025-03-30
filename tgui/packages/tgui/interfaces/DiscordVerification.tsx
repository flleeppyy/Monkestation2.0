import { useBackend, useLocalState } from '../backend';
import { Component, createRef, RefObject } from 'inferno';
import { Box, Button, Divider, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';

interface DiscordVerificationData {
  verification_code: string;
  discord_invite: string;
}

export const DiscordVerification = (props, context) => {
  const { act, data } = useBackend<DiscordVerificationData>();
  const { verification_code, discord_invite } = data;

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
              Click "Copy to Clipboard" or manually copy the code above.
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
              Select <b>MRP1 or MRP2</b> from the server dropdown. (It doesn't
              matter)
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
