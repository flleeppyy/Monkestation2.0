import { round } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Image,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from '../components';
import { formatTime } from '../format';
import { Window } from '../layouts';
import { getThumbnailUrl } from '../../common/other';
import { Component } from 'inferno';

type Song = {
  name: string;
  url: string;
  length: number; // in seconds
};
type Cassette = {
  name: string;
  desc: string;
  author: string;
  songs: Song[];
};
enum CassetteSide {
  A = 0,
  B,
}
type Data = {
  broadcasting: boolean;
  song_cooldown: number;
  progress: number; // 0–1 for UI bar
  cassette: Cassette;
  side: CassetteSide;
  current_song: Song;
};

class Controls extends Component<{ data: Data }> {
  state: {
    thumbnailUrl: string | null;
  };
  constructor(props: { data: Data }) {
    super(props);
    this.state = { thumbnailUrl: null };
  }

  componentDidMount() {
    console.table('meow');
    this.fetchThumbnail();
  }

  componentDidUpdate(prevProps) {
    console.table('component did update');
    if (this.props.data?.current_song?.url !== prevProps?.current_song?.url) {
      this.fetchThumbnail();
    }
  }

  async fetchThumbnail() {
    console.table('fetch thumbnail');
    const { current_song } = this.props?.data || {};
    if (!current_song) return;
    if (current_song?.url) {
      const thumb = await getThumbnailUrl(current_song?.url);
      this.setState({ thumbnailUrl: thumb });
    }
  }

  render() {
    const { act } = useBackend();
    const { progress, broadcasting, current_song, song_cooldown } =
      this.props.data;
    const { thumbnailUrl } = this.state;

    return (
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Title">
              <Box>
                {broadcasting && current_song ? current_song.name : 'Stopped'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Controls">
              <Button
                icon="play"
                disabled={broadcasting}
                onClick={() => act('play')}
                tooltip={
                  song_cooldown
                    ? `The DJ station needs time to cool down after playing the last song. Time left: ${formatTime(song_cooldown, 'short')}`
                    : null
                }
              >
                Play
              </Button>
              <Button
                icon="stop"
                disabled={!broadcasting}
                onClick={() => act('stop')}
              >
                Stop
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Progress">
              <ProgressBar value={progress} maxValue={1} color="good">
                {broadcasting && current_song
                  ? `${formatTime(progress * current_song.length, 'short')} / ${formatTime(
                      current_song.length,
                      'short',
                    )}`
                  : 'N/A'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          {thumbnailUrl && (
            <Box mt={2} textAlign="center">
              <Image
                src={thumbnailUrl}
                alt="Track thumbnail"
                style={{ maxWidth: '100%', borderRadius: '8px' }}
              />
            </Box>
          )}
        </Stack.Item>
      </Stack>
    );
  }
}

const AvailableTracks = ({ songs }: { songs: Song[] }) => {
  const { act, data } = useBackend<Data>();
  const { progress } = data;

  const cassette = data?.cassette;

  const currentSong = cassette?.songs?.length
    ? cassette.songs[Math.floor(progress * cassette.songs.length)]
    : null;

  return (
    <Stack vertical fill>
      {songs.map((song, i) => (
        <Stack.Item key={i}>
          <Button
            fluid
            icon="play"
            selected={currentSong?.name === song.name}
            onClick={() => act('set_track', { index: i })}
          >
            {song.name}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const DjStation = () => {
  const { act, data } = useBackend<Data>();
  const { current_song, side } = data;

  const cassette = data?.cassette;

  const songs = cassette?.songs ?? [];

  return (
    <Window title="DJ Station" width={1000} height={650} resizable>
      <Window.Content>
        <Stack horizontal fill>
          <Stack.Item grow={1}>
            <Stack vertical fill>
              {/* Tape Info Section */}
              <Section
                title="Tape Info"
                buttons={
                  <Button fluid icon="eject" onClick={() => act('eject')}>
                    Eject
                  </Button>
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Tape Author">
                    {cassette?.author || 'Unknown'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Description">
                    {cassette?.desc || 'No description'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Total Tracks">
                    {songs.length}
                  </LabeledList.Item>
                  <LabeledList.Item label="Total Duration">
                    {songs.length
                      ? formatTime(
                          songs.reduce((sum, s) => sum + s.length, 0),
                          'default',
                        )
                      : 'N/A'}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
              <Section fill scrollable title={`Side ${side ? 'A' : 'B'}`}>
                {songs.length ? (
                  <AvailableTracks
                    songs={songs.filter((_, i) => i % 2 === 0)}
                  />
                ) : (
                  <Box color="bad">
                    {cassette ? 'No songs on this side.' : 'No tape inserted'}
                  </Box>
                )}
              </Section>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section title="Currently Playing" fill>
              <Controls data={data}></Controls>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
