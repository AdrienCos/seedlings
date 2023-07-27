from unittest.mock import patch

from click.testing import CliRunner

from {{cookiecutter.project_slug}}.cli import main


class TestCLI:
    def test_call_without_args_works(self) -> None:
        # Given
        runner = CliRunner()

        # When
        with patch("{{cookiecutter.project_slug}}.cli.ExampleClass", autospec=True) as mock_module:
            result = runner.invoke(main, args=None)

        # Then
        mock_module.assert_called_once()
        assert 0 == result.exit_code

    def test_call_with_args_works(self) -> None:
        # Given
        runner = CliRunner()

        # When
        with patch("{{cookiecutter.project_slug}}.cli.ExampleClass", autospec=True) as mock_module:
            result = runner.invoke(main, args=["--iterations", "10"])

        # Then
        assert result.exception is None
        assert 0 == result.exit_code
        mock_module.assert_called_once()
