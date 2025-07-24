--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 17.1

-- Started on 2025-07-24 12:33:32

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: ginger_prod_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO ginger_prod_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 19479)
-- Name: app_user; Type: TABLE; Schema: public; Owner: ginger_prod_user
--

CREATE TABLE public.app_user (
    id integer NOT NULL,
    email text NOT NULL,
    phone text,
    display_name text,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_active_at timestamp with time zone,
    staff boolean DEFAULT false NOT NULL,
    email_verified boolean DEFAULT false NOT NULL,
    auth_token text,
    auth_token_expires timestamp with time zone,
    staff_admin boolean DEFAULT false
);


ALTER TABLE public.app_user OWNER TO ginger_prod_user;

--
-- TOC entry 215 (class 1259 OID 19478)
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: public; Owner: ginger_prod_user
--

CREATE SEQUENCE public.app_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_user_id_seq OWNER TO ginger_prod_user;

--
-- TOC entry 3463 (class 0 OID 0)
-- Dependencies: 215
-- Name: app_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ginger_prod_user
--

ALTER SEQUENCE public.app_user_id_seq OWNED BY public.app_user.id;


--
-- TOC entry 218 (class 1259 OID 19494)
-- Name: loyalty_points; Type: TABLE; Schema: public; Owner: ginger_prod_user
--

CREATE TABLE public.loyalty_points (
    id integer NOT NULL,
    user_id integer NOT NULL,
    current_points integer DEFAULT 0 NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.loyalty_points OWNER TO ginger_prod_user;

--
-- TOC entry 217 (class 1259 OID 19493)
-- Name: loyalty_points_id_seq; Type: SEQUENCE; Schema: public; Owner: ginger_prod_user
--

CREATE SEQUENCE public.loyalty_points_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.loyalty_points_id_seq OWNER TO ginger_prod_user;

--
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 217
-- Name: loyalty_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ginger_prod_user
--

ALTER SEQUENCE public.loyalty_points_id_seq OWNED BY public.loyalty_points.id;


--
-- TOC entry 220 (class 1259 OID 19504)
-- Name: point_transactions; Type: TABLE; Schema: public; Owner: ginger_prod_user
--

CREATE TABLE public.point_transactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    scanned_by integer,
    points_amount integer NOT NULL,
    description text,
    transaction_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.point_transactions OWNER TO ginger_prod_user;

--
-- TOC entry 219 (class 1259 OID 19503)
-- Name: point_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: ginger_prod_user
--

CREATE SEQUENCE public.point_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.point_transactions_id_seq OWNER TO ginger_prod_user;

--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 219
-- Name: point_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ginger_prod_user
--

ALTER SEQUENCE public.point_transactions_id_seq OWNED BY public.point_transactions.id;


--
-- TOC entry 226 (class 1259 OID 19538)
-- Name: reward_redemptions; Type: TABLE; Schema: public; Owner: ginger_prod_user
--

CREATE TABLE public.reward_redemptions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer NOT NULL,
    staff_user_id integer NOT NULL,
    points_used integer NOT NULL,
    redemption_date timestamp with time zone DEFAULT now() NOT NULL,
    notes text
);


ALTER TABLE public.reward_redemptions OWNER TO ginger_prod_user;

--
-- TOC entry 225 (class 1259 OID 19537)
-- Name: reward_redemptions_id_seq; Type: SEQUENCE; Schema: public; Owner: ginger_prod_user
--

CREATE SEQUENCE public.reward_redemptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reward_redemptions_id_seq OWNER TO ginger_prod_user;

--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 225
-- Name: reward_redemptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ginger_prod_user
--

ALTER SEQUENCE public.reward_redemptions_id_seq OWNED BY public.reward_redemptions.id;


--
-- TOC entry 224 (class 1259 OID 19526)
-- Name: rewards; Type: TABLE; Schema: public; Owner: ginger_prod_user
--

CREATE TABLE public.rewards (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    points_required integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.rewards OWNER TO ginger_prod_user;

--
-- TOC entry 223 (class 1259 OID 19525)
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: ginger_prod_user
--

CREATE SEQUENCE public.rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rewards_id_seq OWNER TO ginger_prod_user;

--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 223
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ginger_prod_user
--

ALTER SEQUENCE public.rewards_id_seq OWNED BY public.rewards.id;


--
-- TOC entry 222 (class 1259 OID 19516)
-- Name: user_qr_codes; Type: TABLE; Schema: public; Owner: ginger_prod_user
--

CREATE TABLE public.user_qr_codes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    qr_code_data text NOT NULL
);


ALTER TABLE public.user_qr_codes OWNER TO ginger_prod_user;

--
-- TOC entry 221 (class 1259 OID 19515)
-- Name: user_qr_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: ginger_prod_user
--

CREATE SEQUENCE public.user_qr_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_qr_codes_id_seq OWNER TO ginger_prod_user;

--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 221
-- Name: user_qr_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ginger_prod_user
--

ALTER SEQUENCE public.user_qr_codes_id_seq OWNED BY public.user_qr_codes.id;


--
-- TOC entry 3276 (class 2604 OID 19482)
-- Name: app_user id; Type: DEFAULT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.app_user ALTER COLUMN id SET DEFAULT nextval('public.app_user_id_seq'::regclass);


--
-- TOC entry 3281 (class 2604 OID 19497)
-- Name: loyalty_points id; Type: DEFAULT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.loyalty_points ALTER COLUMN id SET DEFAULT nextval('public.loyalty_points_id_seq'::regclass);


--
-- TOC entry 3284 (class 2604 OID 19507)
-- Name: point_transactions id; Type: DEFAULT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.point_transactions ALTER COLUMN id SET DEFAULT nextval('public.point_transactions_id_seq'::regclass);


--
-- TOC entry 3291 (class 2604 OID 19541)
-- Name: reward_redemptions id; Type: DEFAULT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.reward_redemptions ALTER COLUMN id SET DEFAULT nextval('public.reward_redemptions_id_seq'::regclass);


--
-- TOC entry 3287 (class 2604 OID 19529)
-- Name: rewards id; Type: DEFAULT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.rewards ALTER COLUMN id SET DEFAULT nextval('public.rewards_id_seq'::regclass);


--
-- TOC entry 3286 (class 2604 OID 19519)
-- Name: user_qr_codes id; Type: DEFAULT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.user_qr_codes ALTER COLUMN id SET DEFAULT nextval('public.user_qr_codes_id_seq'::regclass);


--
-- TOC entry 3294 (class 2606 OID 19491)
-- Name: app_user app_user_email_key; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_email_key UNIQUE (email);


--
-- TOC entry 3296 (class 2606 OID 19489)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3300 (class 2606 OID 19501)
-- Name: loyalty_points loyalty_points_pkey; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.loyalty_points
    ADD CONSTRAINT loyalty_points_pkey PRIMARY KEY (id);


--
-- TOC entry 3304 (class 2606 OID 19512)
-- Name: point_transactions point_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.point_transactions
    ADD CONSTRAINT point_transactions_pkey PRIMARY KEY (id);


--
-- TOC entry 3314 (class 2606 OID 19546)
-- Name: reward_redemptions reward_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT reward_redemptions_pkey PRIMARY KEY (id);


--
-- TOC entry 3309 (class 2606 OID 19536)
-- Name: rewards rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- TOC entry 3307 (class 2606 OID 19523)
-- Name: user_qr_codes user_qr_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.user_qr_codes
    ADD CONSTRAINT user_qr_codes_pkey PRIMARY KEY (id);


--
-- TOC entry 3297 (class 1259 OID 19550)
-- Name: idx_app_user_display_name; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_app_user_display_name ON public.app_user USING btree (display_name);


--
-- TOC entry 3298 (class 1259 OID 19502)
-- Name: idx_loyalty_points_user_id; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_loyalty_points_user_id ON public.loyalty_points USING btree (user_id);


--
-- TOC entry 3301 (class 1259 OID 19514)
-- Name: idx_point_transactions_scanned_by; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_point_transactions_scanned_by ON public.point_transactions USING btree (scanned_by);


--
-- TOC entry 3302 (class 1259 OID 19513)
-- Name: idx_point_transactions_user_id; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_point_transactions_user_id ON public.point_transactions USING btree (user_id);


--
-- TOC entry 3310 (class 1259 OID 19548)
-- Name: idx_reward_redemptions_reward_id; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_reward_redemptions_reward_id ON public.reward_redemptions USING btree (reward_id);


--
-- TOC entry 3311 (class 1259 OID 19549)
-- Name: idx_reward_redemptions_staff_user_id; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_reward_redemptions_staff_user_id ON public.reward_redemptions USING btree (staff_user_id);


--
-- TOC entry 3312 (class 1259 OID 19547)
-- Name: idx_reward_redemptions_user_id; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_reward_redemptions_user_id ON public.reward_redemptions USING btree (user_id);


--
-- TOC entry 3305 (class 1259 OID 19524)
-- Name: idx_user_qr_codes_user_id; Type: INDEX; Schema: public; Owner: ginger_prod_user
--

CREATE INDEX idx_user_qr_codes_user_id ON public.user_qr_codes USING btree (user_id);


--
-- TOC entry 2064 (class 826 OID 19477)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO ginger_prod_user;


--
-- TOC entry 2063 (class 826 OID 19476)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO ginger_prod_user;


-- Completed on 2025-07-24 12:33:33

--
-- PostgreSQL database dump complete
--

