export const composioToolMap: Record<string, Record<string, string>> = {
  slack: {
    send_message: "SLACK_SEND_MESSAGE",
    search_messages: "SLACK_SEARCH_MESSAGES",
    list_channels: "SLACK_LIST_CHANNELS"
  },
  gmail: {
    send_email: "GMAIL_SEND_EMAIL",
    search_email: "GMAIL_SEARCH_EMAILS",
    get_email: "GMAIL_FETCH_EMAIL"
  },
  notion: {
    create_page: "NOTION_CREATE_PAGE",
    search_pages: "NOTION_SEARCH_NOTION_PAGE"
  },
  github: {
    create_issue: "GITHUB_CREATE_ISSUE",
    search_repositories: "GITHUB_SEARCH_REPOSITORIES"
  },
  google_drive: {
    search_files: "GOOGLEDRIVE_SEARCH_FILE",
    upload_file: "GOOGLEDRIVE_UPLOAD_FILE"
  },
  zapier: {
    trigger_webhook: "WEBHOOK_POST"
  },
  stripe: {
    list_charges: "STRIPE_LIST_CHARGES",
    list_customers: "STRIPE_LIST_CUSTOMERS"
  }
};

export function getMappedTool(provider: string, toolSlug: string) {
  return composioToolMap[provider]?.[toolSlug] || toolSlug;
}
