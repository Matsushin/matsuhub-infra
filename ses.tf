resource "aws_ses_domain_identity" "ses-domain-identity" {
  domain = var.s3_zone_domain
}
resource "aws_ses_domain_dkim" "ses-domain-kdim" {
  domain = aws_ses_domain_identity.ses-domain-identity.domain
}
resource "aws_ses_domain_mail_from" "ses-domain-mail-from" {
  domain = aws_ses_domain_identity.ses-domain-identity.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.ses-domain-identity.domain}"
}
resource "aws_route53_record" "r53-ses-txt-record" {
  zone_id = var.s3_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.ses-domain-identity.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.ses-domain-identity.verification_token]
}
resource "aws_route53_record" "cname-dkim-ses" {
  count   = 3
  zone_id = var.s3_zone_id
  name    = "${element(aws_ses_domain_dkim.ses-domain-kdim.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.ses-domain-identity.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses-domain-kdim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

## For SPF
resource "aws_route53_record" "mx-mail-ses-mx-record" {
  zone_id = var.s3_zone_id
  name    = aws_ses_domain_mail_from.ses-domain-mail-from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.ap-northeast-1.amazonses.com"] # Ref https://docs.aws.amazon.com/ja_jp/ses/latest/DeveloperGuide/regions.html
}

resource "aws_route53_record" "txt-mail-ses-spf-record" {
  zone_id = var.s3_zone_id
  name    = aws_ses_domain_mail_from.ses-domain-mail-from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

## For DMARC
resource "aws_route53_record" "ses-dmarc-txt-record" {
  zone_id = var.s3_zone_id
  name    = "_dmarc.${aws_ses_domain_identity.ses-domain-identity.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1;p=quarantine;pct=25;rua=mailto:dmarcreports@${aws_ses_domain_identity.ses-domain-identity.domain}"] # Ref https://docs.aws.amazon.com/ja_jp/ses/latest/DeveloperGuide/send-email-authentication-dmarc.html
}
