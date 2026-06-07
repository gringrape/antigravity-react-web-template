import { Text, Title } from '@mantine/core';
import classes from './Welcome.module.css';

export function Welcome() {
  return (
    <>
      <Title className={classes.title} ta="center" mt={120}>
        <Text
          inherit
          variant="gradient"
          component="span"
          gradient={{ from: 'indigo', to: 'cyan' }}
        >
          바이브코딩
        </Text>
        의 세계에
        <br />
        오신걸 환영합니다
      </Title>
      <Text c="dimmed" ta="center" size="lg" maw={580} mx="auto" mt="xl">
        만들고 싶은 것을 말씀하세요.
      </Text>
    </>
  );
}
