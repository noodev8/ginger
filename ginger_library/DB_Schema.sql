--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 17.1

-- Started on 2025-07-24 11:55:01

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
    auth_token_expires timestamp with time zone
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
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 215
-- Name: app_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ginger_prod_user
--

ALTER SEQUENCE public.app_user_id_seq OWNED BY public.app_user.id;


--
-- TOC entry 3251 (class 2604 OID 19482)
-- Name: app_user id; Type: DEFAULT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.app_user ALTER COLUMN id SET DEFAULT nextval('public.app_user_id_seq'::regclass);


--
-- TOC entry 3256 (class 2606 OID 19491)
-- Name: app_user app_user_email_key; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_email_key UNIQUE (email);


--
-- TOC entry 3258 (class 2606 OID 19489)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ginger_prod_user
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 2039 (class 826 OID 19477)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO ginger_prod_user;


--
-- TOC entry 2038 (class 826 OID 19476)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO ginger_prod_user;


-- Completed on 2025-07-24 11:55:02

--
-- PostgreSQL database dump complete
--

