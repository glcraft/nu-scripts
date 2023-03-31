# Nu scripts

This is a collection of scripts I use to make my life easier in [nu](https://nushell.sh).

## OpenAI script

This script uses the [OpenAI API](https://platform.openai.com/) to generate text. 
There are api commands and some prompt commands to make it easier to use.

### Usage

Execute this line in nu :

```nu
use /path/to/scripts/openai.nu
```

### API Commands
```nu
openai api models [--model <model>]
```
Lists the OpenAI models. If model is specified, it will return the details of that model.

#### Parameters

- **model (string)**: ID of the model to to get detail.

---
```nu
openai api completion <model> [--prompt <prompt>] [--suffix <suffix>] [--max_tokens <max_tokens>] [--temperature <temperature>] [--top_p <top_p>] [--n <n>] [--logprobs <logprobs>] [--echo <echo>] [--stop <stop>] [--frequency_penalty <frequency_penalty>] [--presence_penalty <presence_penalty>] [--best-of <best_of>] [--logit_bias <logit_bias>] [--user <user>]
```
Completion API call. 
See [OpenAI docs](https://platform.openai.com/docs/api-reference/completions/create) for more info.

#### Parameters

- **model (string)**: ID of the model to use.

- **--prompt (string)**: The prompt(s) to generate completions for

- **--suffix (string)**: The suffix that comes after a completion of inserted text.

- **--max-tokens (int)**: The maximum number of tokens to generate in the completion.

- **--temperature (number)**: The temperature used to control the randomness of the completion.

- **--top-p (number)**: The top-p used to control the randomness of the completion.

- **--n (int)**: How many completions to generate for each prompt. Use carefully, as it's a token eater.

- **--logprobs (int)**: Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens.

- **--echo (bool)**: Include the prompt in the returned text.

- **--stop (any)**: A list of tokens that, if encountered, will stop the completion.

- **--frequency-penalty (number)**: A penalty to apply to each token that appears more than once in the completion.

- **--presence-penalty (number)**: A penalty to apply if the specified tokens don't appear in the completion.

- **--best-of (int)**: Generates best_of completions server-side and returns the "best" (the one with the highest log probability per token). Use carefully, as it's a token eater.

- **--logit-bias (record)**: A record to modify the likelihood of specified tokens appearing in the completion

- **--user (string)**: A unique identifier representing your end-user.

---
```nu
openai api chat-completion <model> <messages> [--max_tokens <max_tokens>] [--temperature <temperature>] [--top_p <top_p>] [--n <n>] [--stop <stop>] [--frequency_penalty <frequency_penalty>] [--presence_penalty <presence_penalty>] [--logit_bias <logit_bias>] [--user <user>]
```

Chat completion API call. 
See [OpenAI docs](https://platform.openai.com/docs/api-reference/chat/create) for more info.

#### Parameters

- **model (string)**: ID of the model to use.

- **messages (list)**: List of messages to complete from.

- **--max-tokens (int)**: The maximum number of tokens to generate in the completion.

- **--temperature (number)**: The temperature used to control the randomness of the completion.

- **--top-p (number)**: The top-p used to control the randomness of the completion.

- **--n (int)**: How many completions to generate for each prompt. Use carefully, as it's a token eater.

- **--stop (any)**: A list of tokens that, if encountered, will stop the completion.

- **--frequency-penalty (number)**: A penalty to apply to each token that appears more than once in the completion.

- **--presence-penalty (number)**: A penalty to apply if the specified tokens don't appear in the completion.

- **--logit-bias (record)**: A record to modify the likelihood of specified tokens appearing in the completion

- **--user (string)**: A unique identifier representing your end-user.

### Prompt Commands



