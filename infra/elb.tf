resource "aws_security_group" "alb" {
  name        = "${local.prefix}-alb"
  description = "Allow ingress and egrees traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb" "alb" {
  name                       = "${local.prefix}-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [for subnet in aws_subnet.private : subnet.id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "health" {
  listener_arn = aws_lb_listener.alb.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/health"]
    }
  }
}

resource "aws_lb_listener_rule" "mock" {
  listener_arn = aws_lb_listener.alb.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "{ \"message\" : \"Yeap! Its me!\"}"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/process/webhook"]
    }
  }
}


resource "aws_security_group" "nlb" {
  name        = "${local.prefix}-nlb"
  description = "Allow ingress and egrees traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #cidr_blocks = [aws_vpc.this.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb" "nlb" {
  name                       = "${local.prefix}-nlb"
  internal                   = true
  load_balancer_type         = "network"
  security_groups            = [aws_security_group.nlb.id]
  subnets                    = [for subnet in aws_subnet.private : subnet.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "alb" {
  name        = "${local.prefix}-tg-alb"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.this.id

  health_check {
    enabled  = true
    path     = "/health"
    port     = 80
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "alb" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_lb.alb.arn
  port             = 80
}

resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}
