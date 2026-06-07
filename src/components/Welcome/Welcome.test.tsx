import { render, screen } from '@test-utils';
import { Welcome } from './Welcome';

describe('Welcome component', () => {
  it('renders the welcome heading', () => {
    render(<Welcome />);
    expect(screen.getByText('바이브코딩')).toBeInTheDocument();
    expect(screen.getByText(/오신걸 환영합니다/)).toBeInTheDocument();
  });
});
